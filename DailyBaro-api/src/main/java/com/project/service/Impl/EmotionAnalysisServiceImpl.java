package com.project.service.Impl;

import com.project.mapper.DiaryMapper;
import com.project.mapper.DiaryTagMapper;
import com.project.mapper.TagMapper;
import com.project.model.Diary;
import com.project.model.DiaryTag;
import com.project.model.Tag;
import com.project.model.vo.EmotionDataPointVO;
import com.project.model.vo.EmotionShareVO;
import com.project.service.AIService;
import com.project.service.EmotionAnalysisService;
import com.project.util.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

@Slf4j
@Service
public class EmotionAnalysisServiceImpl implements EmotionAnalysisService {

    @Autowired
    private DiaryMapper diaryMapper;
    @Autowired
    private DiaryTagMapper diaryTagMapper;
    @Autowired
    private TagMapper tagMapper;
    @Autowired
    @Qualifier("deepSeekAIService")
    private AIService aiService;

    private static final Map<String, Double> EMOTION_MAP = new HashMap<>();

    static {
        EMOTION_MAP.put("开心", 1.0);
        EMOTION_MAP.put("激动", 0.8);
        EMOTION_MAP.put("平静", 0.5);
        EMOTION_MAP.put("无聊", 0.0);
        EMOTION_MAP.put("疲惫", -0.4);
        EMOTION_MAP.put("难过", -0.8);
        EMOTION_MAP.put("焦虑", -0.9);
        EMOTION_MAP.put("愤怒", -1.0);
    }

    @Override
    public Result<List<EmotionDataPointVO>> getEmotionFluctuation(Long userId, Date startDate, Date endDate) {
        return getEmotionFluctuation(userId, startDate, endDate, null);
    }
    @Override
    public Result<List<EmotionDataPointVO>> getEmotionFluctuation(Long userId, Date startDate, Date endDate, Long tagId) {
        // 只根据userId和时间区间统计所有日记的情绪波动，不再处理tagId
        List<Diary> diaries = diaryMapper.selectList(null).stream()
            .filter(d -> d.getUserId().equals(userId)
                    && !d.getCreateTime().before(startDate)
                    && !d.getCreateTime().after(endDate))
            .collect(Collectors.toList());
        List<EmotionDataPointVO> result = new ArrayList<>();
        Calendar cal = Calendar.getInstance();
        cal.setTime(startDate);
        while (!cal.getTime().after(endDate)) {
            Date dayStart = getDayStart(cal.getTime());
            Date dayEnd = getDayEnd(cal.getTime());
            // 筛选当天的日记
            List<Diary> dayDiaries = diaries.stream()
                .filter(d -> !d.getCreateTime().before(dayStart) && !d.getCreateTime().after(dayEnd))
                .collect(Collectors.toList());
            List<Double> emotionValues = new ArrayList<>();
            for (Diary diary : dayDiaries) {
                List<String> tags = diaryMapper.findTagsByDiaryId(diary.getDiaryId());
                for (String tag : tags) {
                    if (EMOTION_MAP.containsKey(tag)) {
                        emotionValues.add(EMOTION_MAP.get(tag));
                    }
                }
            }
            Double avg = null;
            if (!emotionValues.isEmpty()) {
                avg = emotionValues.stream().mapToDouble(Double::doubleValue).average().orElse(0);
            }
            EmotionDataPointVO vo = new EmotionDataPointVO();
            vo.setDate(new java.sql.Date(dayStart.getTime()));
            vo.setValue(avg);
            result.add(vo);
            cal.add(Calendar.DATE, 1);
        }
        return Result.success(result);
    }

    // 工具方法：获取一天的起始和结束时间
    private Date getDayStart(Date date) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        return cal.getTime();
    }
    private Date getDayEnd(Date date) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        cal.set(Calendar.HOUR_OF_DAY, 23);
        cal.set(Calendar.MINUTE, 59);
        cal.set(Calendar.SECOND, 59);
        cal.set(Calendar.MILLISECOND, 999);
        return cal.getTime();
    }

    @Override
    public Result<List<EmotionShareVO>> getEmotionDistribution(Long userId, Date startDate, Date endDate) {
        return getEmotionDistribution(userId, startDate, endDate, (Long) null);
    }
    @Override
    public Result<List<EmotionShareVO>> getEmotionDistribution(Long userId, Date startDate, Date endDate, Long tagId) {
        List<String> allTags;
        if (tagId != null) {
            List<Long> diaryIds = diaryTagMapper.findDiaryIdsByTagIds(Collections.singletonList(tagId));
            if (diaryIds.isEmpty()) {
                return Result.success(Collections.emptyList());
            }
            allTags = new ArrayList<>();
            for (Long diaryId : diaryIds) {
                allTags.addAll(diaryMapper.findTagsByDiaryId(diaryId));
            }
        } else {
            allTags = diaryMapper.findTagsByUserIdAndDateRange(userId, startDate, endDate);
        }
        if (allTags.isEmpty()) {
            return Result.success(Collections.emptyList());
        }
        Map<String, Long> emotionCounts = allTags.stream()
                .filter(EMOTION_MAP::containsKey)
                .collect(Collectors.groupingBy(Function.identity(), Collectors.counting()));
        long totalEmotions = emotionCounts.values().stream().mapToLong(Long::longValue).sum();
        if (totalEmotions == 0) {
            return Result.success(Collections.emptyList());
        }
        List<EmotionShareVO> result = emotionCounts.entrySet().stream()
                .map(entry -> new EmotionShareVO(entry.getKey(), (double) entry.getValue() / totalEmotions * 100))
                .sorted(Comparator.comparing(EmotionShareVO::getPercentage).reversed())
                .collect(Collectors.toList());
        return Result.success(result);
    }

    @Override
    public Result<List<Map<String, Object>>> getEmotionFluctuationMulti(Long userId, Date startDate, Date endDate) {
        // 获取基础情绪波动数据
        Result<List<EmotionDataPointVO>> fluctuationResult = getEmotionFluctuation(userId, startDate, endDate);
        if (fluctuationResult.getCode() != 200) {
            return Result.fail(fluctuationResult.getMessage());
        }
        
        List<EmotionDataPointVO> baseData = fluctuationResult.getData();
        List<Map<String, Object>> multiData = new ArrayList<>();
        
        // 为每个日期创建多维度情绪数据
        for (EmotionDataPointVO point : baseData) {
            Map<String, Object> dayData = new HashMap<>();
            dayData.put("date", point.getDate());
            
            // 根据情绪值生成各情绪的数据
            Double emotionValue = point.getValue();
            if (emotionValue != null) {
                // 根据情绪值映射到各情绪类型
                dayData.put("开心", emotionValue > 0.5 ? emotionValue * 0.8 : 0);
                dayData.put("激动", emotionValue > 0.3 ? emotionValue * 0.6 : 0);
                dayData.put("平静", Math.abs(emotionValue) < 0.2 ? 0.5 : 0);
                dayData.put("无聊", emotionValue < -0.3 ? Math.abs(emotionValue) * 0.4 : 0);
                dayData.put("疲惫", emotionValue < -0.5 ? Math.abs(emotionValue) * 0.6 : 0);
                dayData.put("难过", emotionValue < -0.7 ? Math.abs(emotionValue) * 0.8 : 0);
                dayData.put("焦虑", emotionValue < -0.8 ? Math.abs(emotionValue) * 0.9 : 0);
                dayData.put("愤怒", emotionValue < -0.9 ? Math.abs(emotionValue) : 0);
            } else {
                // 如果没有情绪数据，设置默认值
                dayData.put("开心", 0);
                dayData.put("激动", 0);
                dayData.put("平静", 0);
                dayData.put("无聊", 0);
                dayData.put("疲惫", 0);
                dayData.put("难过", 0);
                dayData.put("焦虑", 0);
                dayData.put("愤怒", 0);
            }
            
            multiData.add(dayData);
        }
        
        return Result.success(multiData);
    }

    @Override
    public Result<List<String>> getAIAnalysisPoints(Map<String, Object> emotionData) {
        List<String> analysisPoints = new ArrayList<>();
        
        try {
            // 分析情绪数据并生成AI分析点
            List<Map<String, Object>> fluctuation = (List<Map<String, Object>>) emotionData.get("fluctuation");
            List<Map<String, Object>> distribution = (List<Map<String, Object>>) emotionData.get("distribution");
            
            // 构建分析数据
            StringBuilder analysisData = new StringBuilder();
            analysisData.append("情绪分析数据：\n");
            
            if (fluctuation != null && !fluctuation.isEmpty()) {
                analysisData.append("情绪波动数据：").append(fluctuation.size()).append("天的数据\n");
                // 计算情绪波动趋势
                double avgFluctuation = fluctuation.stream()
                    .mapToDouble(d -> {
                        double total = 0;
                        int count = 0;
                        for (String emotion : new String[]{"开心", "激动", "平静", "无聊", "疲惫", "难过", "焦虑", "愤怒"}) {
                            Object value = d.get(emotion);
                            if (value instanceof Number) {
                                total += ((Number) value).doubleValue();
                                count++;
                            }
                        }
                        return count > 0 ? total / count : 0;
                    })
                    .average()
                    .orElse(0);
                analysisData.append("平均情绪波动值：").append(String.format("%.2f", avgFluctuation)).append("\n");
            }
            
            if (distribution != null && !distribution.isEmpty()) {
                analysisData.append("情绪分布数据：\n");
                for (Map<String, Object> dist : distribution) {
                    String emotion = (String) dist.get("emotion");
                    Object percentageObj = dist.get("percentage");
                    if (emotion != null && percentageObj != null) {
                        double percentage = 0.0;
                        if (percentageObj instanceof Number) {
                            percentage = ((Number) percentageObj).doubleValue();
                        }
                        analysisData.append(emotion).append(": ").append(String.format("%.1f", percentage)).append("%\n");
                    }
                }
            }
            
            // 调用AI服务进行四维度分析
            String aiPrompt = "请基于以下情绪数据，从四个维度进行分析：\n" +
                "1. 情绪稳定性分析\n" +
                "2. 情绪健康度评估\n" +
                "3. 情绪调节建议\n" +
                "4. 个性化改善方案\n\n" +
                "数据：" + analysisData.toString() + "\n" +
                "请为每个维度提供一条简洁实用的分析建议，每条不超过20字。";
            
            // 调用AI服务
            Result<String> aiResponse = callAIService(aiPrompt);
            if (aiResponse.getCode() == 200 && aiResponse.getData() != null) {
                String response = aiResponse.getData();
                // 解析AI响应，提取四个维度的分析
                String[] lines = response.split("\n");
                for (String line : lines) {
                    line = line.trim();
                    if (!line.isEmpty() && (line.contains("1.") || line.contains("2.") || 
                                         line.contains("3.") || line.contains("4.") ||
                                         line.contains("情绪") || line.contains("建议") || 
                                         line.contains("分析") || line.contains("改善"))) {
                        // 提取分析内容
                        String content = line.replaceAll("^[0-9]+\\.\\s*", "").trim();
                        // 移除markdown格式字符
                        content = content.replaceAll("\\*\\*", "").replaceAll("\\*", "")
                                       .replaceAll("`", "").replaceAll("#", "")
                                       .replaceAll("\\[", "").replaceAll("\\]", "")
                                       .replaceAll("\\(", "").replaceAll("\\)", "")
                                       .replaceAll("\\{", "").replaceAll("\\}", "")
                                       .replaceAll("\\|", "").replaceAll("~", "")
                                       .replaceAll(">", "").replaceAll("<", "")
                                       .replaceAll("_", "").replaceAll("-", "")
                                       .trim();
                        if (content.length() > 0 && content.length() <= 30) {
                            analysisPoints.add(content);
                        }
                    }
                }
            }
            
            // 如果AI分析失败或结果不足，提供默认分析
            if (analysisPoints.size() < 4) {
                if (fluctuation != null && !fluctuation.isEmpty()) {
                    analysisPoints.add("情绪波动较大，建议保持规律作息");
                    analysisPoints.add("多进行户外活动，增加社交互动");
                    analysisPoints.add("学习情绪管理技巧，建立调节机制");
                } else {
                    analysisPoints.add("保持规律作息，有助于情绪稳定");
                    analysisPoints.add("多进行户外活动，增加社交互动");
                    analysisPoints.add("学习情绪管理技巧，建立调节机制");
                }
                analysisPoints.add("必要时寻求专业心理咨询帮助");
            }
            
            // 确保返回4个分析点
            while (analysisPoints.size() < 4) {
                analysisPoints.add("培养积极兴趣爱好，丰富生活内容");
            }
            
            return Result.success(analysisPoints.subList(0, Math.min(4, analysisPoints.size())));
        } catch (Exception e) {
            log.error("生成AI分析点失败", e);
            return Result.fail("AI分析失败: " + e.getMessage());
        }
    }
    
    /**
     * 调用AI服务
     */
    private Result<String> callAIService(String prompt) {
        try {
            // 调用真实的AI服务
            Result<String> aiResponse = aiService.getGeneralResponse(prompt);
            if (aiResponse.getCode() == 200 && aiResponse.getData() != null) {
                return aiResponse;
            } else {
                // 如果AI服务失败，返回默认分析
                String defaultResponse = "1. 情绪稳定性分析：您的情绪波动在正常范围内，建议保持当前状态\n" +
                                      "2. 情绪健康度评估：整体情绪健康，继续保持积极心态\n" +
                                      "3. 情绪调节建议：建议多进行户外活动，增加社交互动\n" +
                                      "4. 个性化改善方案：培养积极兴趣爱好，丰富生活内容";
                return Result.success(defaultResponse);
            }
        } catch (Exception e) {
            log.error("调用AI服务失败", e);
            // 返回默认分析
            String defaultResponse = "1. 情绪稳定性分析：您的情绪波动在正常范围内，建议保持当前状态\n" +
                                  "2. 情绪健康度评估：整体情绪健康，继续保持积极心态\n" +
                                  "3. 情绪调节建议：建议多进行户外活动，增加社交互动\n" +
                                  "4. 个性化改善方案：培养积极兴趣爱好，丰富生活内容";
            return Result.success(defaultResponse);
        }
    }
} 
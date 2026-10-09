<template>
  <div class="analysis-bg">
    <div class="analysis-card" ref="analysisContentRef">
      <h2 class="analysis-title">情绪分析洞察</h2>
      <div class="analysis-desc">通过数据可视化探索你的情绪世界，发现情绪模式，获取个性化洞察</div>
      <div v-if="!uid" class="empty-state">请先登录</div>
      <template v-else>
      <!-- 时间范围选择区 -->
      <div class="time-select-bar">
        <label>时间范围：</label>
        <select v-model="selectedTimeRange" @change="onTimeRangeChange">
          <option v-for="range in timeRangeList" :key="range.id" :value="range.id">{{ range.name }}</option>
        </select>
      </div>
      <div v-if="!emotionData.fluctuation.length && !emotionData.distribution.length" class="empty-state">
        暂无情绪数据
      </div>
      <div v-else class="charts-container">
        <!-- 左侧：情绪波动曲线图 -->
        <div class="chart-section card-hoverable" :class="{ 'card-active': activeCard==='line' }" @mouseenter="activeCard='line'" @mouseleave="activeCard=''">
          <div class="chart-header">
            <span class="chart-title">情绪波动趋势</span>
            <div class="chart-actions">
              <div class="download-dropdown">
                <button class="chart-btn download-btn" @click="toggleLineDownloadMenu">下载 ▼</button>
                <div v-if="showLineDownloadMenu" class="download-menu">
                  <button class="download-option" @click="exportLineImage">图片</button>
                  <button class="download-option" @click="exportLinePDF">PDF</button>
                </div>
              </div>
              <button class="chart-btn" @click="showLineDialog=true">放大</button>
            </div>
          </div>
          <div v-if="emotionData.fluctuation.length" id="line-chart" class="chart-box"></div>
          <div v-else class="empty-state">暂无情绪波动数据</div>
        </div>
        <!-- 右侧：情绪分布饼图 -->
        <div class="chart-section card-hoverable" :class="{ 'card-active': activeCard==='pie' }" @mouseenter="activeCard='pie'" @mouseleave="activeCard=''">
          <div class="chart-header">
            <span class="chart-title">情绪分布比例</span>
            <div class="chart-actions">
              <div class="download-dropdown">
                <button class="chart-btn download-btn" @click="togglePieDownloadMenu">下载 ▼</button>
                <div v-if="showPieDownloadMenu" class="download-menu">
                  <button class="download-option" @click="exportPieImage">图片</button>
                  <button class="download-option" @click="exportPiePDF">PDF</button>
                </div>
              </div>
              <button class="chart-btn" @click="showPieDialog=true">放大</button>
            </div>
          </div>
          <div v-if="emotionData.distribution.length" id="pie-chart" class="chart-box"></div>
          <div v-else class="empty-state">暂无情绪分布数据</div>
          <div class="dominant-emotion-bar">
            <span>主导情绪：</span>
            <span v-if="dominantEmotion" :style="{ 
              color: getEmotionColor(dominantEmotion.emotion), 
              fontWeight: 'bold', 
              fontSize: '18px',
              textShadow: '0 1px 2px rgba(0,0,0,0.1)',
              padding: '4px 8px',
              borderRadius: '6px',
              backgroundColor: getEmotionColor(dominantEmotion.emotion) + '20'
            }">{{ dominantEmotion.emotion }}</span>
            <span v-else>暂无数据</span>
            <div v-if="dominantEmotion" class="dominant-emotion-desc">你在这段时间保持了较好的情绪稳定性</div>
          </div>
        </div>
      </div>
      <!-- AI分析四分区 -->
      <div class="ai-analysis-4">
        <div v-if="aiPoints.length" v-for="(item, idx) in aiPoints" :key="idx" class="ai-card card-hoverable" :class="{ 'card-active': activeCard===('ai'+idx) }" @mouseenter="activeCard='ai'+idx" @mouseleave="activeCard=''">
          <div class="ai-point-title">AI分析{{ idx+1 }}</div>
          <div class="ai-point-content">{{ item }}</div>
        </div>
        <div v-else class="empty-state">暂无AI分析数据</div>
      </div>
      <!-- 放大弹窗 -->
      <div v-if="showLineDialog" class="dialog-mask" @click.self="showLineDialog=false">
        <div class="dialog-content"><div id="line-chart-big" class="chart-box-big"></div></div>
      </div>
      <div v-if="showPieDialog" class="dialog-mask" @click.self="showPieDialog=false">
        <div class="dialog-content"><div id="pie-chart-big" class="chart-box-big"></div></div>
      </div>
      </template>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted, watch, nextTick, computed } from 'vue'
import * as echarts from 'echarts'
import request from '@/utils/request'
import html2canvas from 'html2canvas'
import jsPDF from 'jspdf'
// 时间范围选择相关
const timeRangeList = ref([
  { id: 'week', name: '最近一周' },
  { id: 'month', name: '最近一月' },
  { id: 'year', name: '最近一年' }
])
const selectedTimeRange = ref('week')
function onTimeRangeChange() { 
  updateDateRange()
  loadCharts() 
}

const aiPoints = ref([])
const aiLoading = ref(false)
const startDate = ref('')
const endDate = ref('')

// 更新日期范围
function updateDateRange() {
  const now = new Date()
  const end = now.toISOString().slice(0, 10)
  
  switch (selectedTimeRange.value) {
    case 'week':
      const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
      startDate.value = weekAgo.toISOString().slice(0, 10)
      break
    case 'month':
      const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000)
      startDate.value = monthAgo.toISOString().slice(0, 10)
      break
    case 'year':
      const yearAgo = new Date(now.getTime() - 365 * 24 * 60 * 60 * 1000)
      startDate.value = yearAgo.toISOString().slice(0, 10)
      break
    default:
      const defaultWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
      startDate.value = defaultWeekAgo.toISOString().slice(0, 10)
  }
  
  endDate.value = end
}
const lineChart = ref(null)
const pieChart = ref(null)
const analysisContentRef = ref(null)
const emotionData = ref({ fluctuation: [], distribution: [] })
const aiCache = ref(new Map()) // 缓存AI分析结果
const uid = window.sessionStorage.getItem('uid')
const showLineDialog = ref(false)
const showPieDialog = ref(false)
const showLineDownloadMenu = ref(false)
const showPieDownloadMenu = ref(false)
const activeCard = ref('')

function formatDate(ts) {
  const d = new Date(ts)
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

async function loadCharts() {
  if (!uid) {
    emotionData.value = { fluctuation: [], distribution: [] }
    return
  }
  const userId = uid
  const params = { userId, startDate: startDate.value, endDate: endDate.value }

  try {
    // 多情绪曲线和分布
    const [res1, res2] = await Promise.all([
      request.get('/api/analysis/fluctuation-multi', { params }),
      request.get('/api/analysis/distribution', { params })
    ])
    console.log('fluctuation-multi返回', res1.data)
    console.log('distribution返回', res2.data)
    const data1 = res1.data.data || []
    const data2 = res2.data.data || []
    emotionData.value = { fluctuation: data1, distribution: data2 }
    
    // 等待DOM更新后再渲染图表
    await nextTick()
    renderCharts(data1, data2)
    
    setTimeout(() => {
      loadAIPoints()
    }, 500)
  } catch (error) {
    console.error('加载图表数据失败:', error)
  }
}

function renderCharts(fluctuationData, distributionData) {
  console.log('渲染charts', fluctuationData, distributionData)
  
  // 多情绪曲线
  const emotions = ['开心','激动','平静','无聊','疲惫','难过','焦虑','愤怒']
  const xData = fluctuationData.map(d => formatDate(d.date))
  const series = emotions.map(emotion => ({
    name: emotion,
    type: 'line',
    smooth: true,
    data: fluctuationData.map(d => d[emotion] || 0),
    symbol: 'circle',
    symbolSize: 10,
    lineStyle: { width: 3 },
    itemStyle: { color: getEmotionColor(emotion) },
    emphasis: { focus: 'series' }
  }))
  
  // 渲染折线图
  const lineChartDom = document.getElementById('line-chart')
  if (lineChartDom) {
    if (lineChart.value) { lineChart.value.dispose(); }
    lineChart.value = echarts.init(lineChartDom)
    lineChart.value.setOption({
      title: { text: '情绪波动趋势', left: 'center', textStyle: { fontSize: 16, fontWeight: 'bold' } },
      tooltip: { trigger: 'axis' },
      legend: { data: emotions, top: 30 },
      xAxis: { type: 'category', data: xData, axisLabel: { rotate: 45, fontWeight: 'bold' } },
      yAxis: { type: 'value', min: 0, axisLabel: { fontWeight: 'bold' } },
      series
    })
  }

  // 渲染饼图
  const pieChartDom = document.getElementById('pie-chart')
  if (pieChartDom) {
    if (pieChart.value) { pieChart.value.dispose(); }
    pieChart.value = echarts.init(pieChartDom)
    pieChart.value.setOption({
      title: { text: '情绪分布统计', left: 'center', textStyle: { fontSize: 16, fontWeight: 'bold' } },
      tooltip: { 
        trigger: 'item', 
        formatter: function(params) {
          return `${params.seriesName}<br/>${params.name}: ${params.value} (${params.percent}%)`
        },
        backgroundColor: 'rgba(255,255,255,0.9)',
        borderColor: '#ccc',
        borderWidth: 1,
        textStyle: { color: '#333' }
      },
      series: [{
        name: '情绪分布',
        type: 'pie',
        radius: ['40%', '70%'],
        center: ['60%', '50%'],
        data: (distributionData || []).map(d => ({
          name: d.emotion,
          value: d.percentage,
          itemStyle: { color: getEmotionColor(d.emotion) }
        })),
        emphasis: { 
          itemStyle: { 
            shadowBlur: 15, 
            shadowOffsetX: 0, 
            shadowColor: 'rgba(0, 0, 0, 0.6)',
            borderWidth: 2,
            borderColor: '#fff'
          } 
        },
        label: {
          show: false // 不显示标签，只在悬停时显示
        }
      }]
    })
  }
}

function renderLineChart(domId, isBig) {
  const dom = document.getElementById(domId)
  if (!dom) {
    console.warn(`DOM元素 ${domId} 不存在`)
    return
  }
  const emotions = ['开心','激动','平静','无聊','疲惫','难过','焦虑','愤怒']
  const fluctuationData = emotionData.value.fluctuation || []
  const xData = fluctuationData.map(d => formatDate(d.date))
  const series = emotions.map(emotion => ({
    name: emotion,
    type: 'line',
    smooth: true,
    data: fluctuationData.map(d => d[emotion] || 0),
    symbol: 'circle',
    symbolSize: 10,
    lineStyle: { width: 3 },
    itemStyle: { color: getEmotionColor(emotion) },
    emphasis: { focus: 'series' }
  }))
  const chart = echarts.init(dom)
  chart.setOption({
    title: { text: '情绪波动趋势', left: 'center', textStyle: { fontSize: 16, fontWeight: 'bold' } },
    tooltip: { trigger: 'axis' },
    legend: { data: emotions, top: 30 },
    xAxis: { type: 'category', data: xData, axisLabel: { rotate: 45, fontWeight: 'bold' } },
    yAxis: { type: 'value', min: 0, axisLabel: { fontWeight: 'bold' } },
    series
  })
}
function renderPieChart(domId, isBig) {
  const dom = document.getElementById(domId)
  if (!dom) {
    console.warn(`DOM元素 ${domId} 不存在`)
    return
  }
  const distributionData = emotionData.value.distribution || []
  const chart = echarts.init(dom)
  chart.setOption({
    title: { text: '情绪分布统计', left: 'center', textStyle: { fontSize: 16, fontWeight: 'bold' } },
    tooltip: { 
      trigger: 'item', 
      formatter: function(params) {
        return `${params.seriesName}<br/>${params.name}: ${params.value} (${params.percent}%)`
      },
      backgroundColor: 'rgba(255,255,255,0.9)',
      borderColor: '#ccc',
      borderWidth: 1,
      textStyle: { color: '#333' }
    },
    series: [{
      name: '情绪分布',
      type: 'pie',
      radius: ['40%', '70%'],
      center: ['60%', '50%'],
      data: (distributionData || []).map(d => ({
        name: d.emotion,
        value: d.percentage,
        itemStyle: { color: getEmotionColor(d.emotion) }
      })),
      emphasis: { 
        itemStyle: { 
          shadowBlur: 15, 
          shadowOffsetX: 0, 
          shadowColor: 'rgba(0, 0, 0, 0.6)',
          borderWidth: 2,
          borderColor: '#fff'
        } 
      },
      label: {
        show: false // 不显示标签，只在悬停时显示
      }
    }]
  })
}

function getEmotionColor(emotion) {
  const colorMap = {
    '开心': '#4ade80', '激动': '#fbbf24', '平静': '#60a5fa', '无聊': '#9ca3af',
    '疲惫': '#f59e0b', '难过': '#8b5cf6', '焦虑': '#ef4444', '愤怒': '#dc2626'
  }
  return colorMap[emotion] || '#9ca3af'
}

async function loadAIPoints() {
  aiLoading.value = true
  try {
    const res = await request.post('/api/analysis/ai/analysis-points', emotionData.value)
    console.log('AI分析返回', res.data)
    if (res.data.code === 200 && Array.isArray(res.data.data)) {
      aiPoints.value = res.data.data
    } else {
      aiPoints.value = ['AI分析暂时不可用，请稍后重试。']
    }
  } catch (e) {
    console.error('AI分析请求失败:', e)
    aiPoints.value = ['AI分析失败，请检查网络连接后重试。']
  } finally {
    aiLoading.value = false
  }
}

async function exportPDF() {
  if (!analysisContentRef.value) return

  try {
    const canvas = await html2canvas(analysisContentRef.value, {
      scale: 2,
      useCORS: true,
      allowTaint: true
    })

    const imgData = canvas.toDataURL('image/png')
    const pdf = new jsPDF('p', 'mm', 'a4')
    const imgWidth = 210
    const pageHeight = 295
    const imgHeight = (canvas.height * imgWidth) / canvas.width
    let heightLeft = imgHeight

    let position = 0

    pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight)
    heightLeft -= pageHeight

    while (heightLeft >= 0) {
      position = heightLeft - imgHeight
      pdf.addPage()
      pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight)
      heightLeft -= pageHeight
    }

    pdf.save('情绪分析报告.pdf')
  } catch (error) {
    console.error('导出PDF失败:', error)
    alert('导出失败，请重试')
  }
}

async function exportImage() {
  if (!analysisContentRef.value) return

  try {
    const canvas = await html2canvas(analysisContentRef.value, {
      scale: 2,
      useCORS: true,
      allowTaint: true
    })

    const link = document.createElement('a')
    link.download = '情绪分析报告.png'
    link.href = canvas.toDataURL()
    link.click()
  } catch (error) {
    console.error('导出图片失败:', error)
    alert('导出失败，请重试')
  }
}

const dominantEmotion = computed(() => {
  if (!emotionData.value.distribution || emotionData.value.distribution.length === 0) return null
  return emotionData.value.distribution.reduce((max, cur) => (cur.percentage > max.percentage ? cur : max), emotionData.value.distribution[0])
})

// 下载菜单切换函数
function toggleLineDownloadMenu() {
  showLineDownloadMenu.value = !showLineDownloadMenu.value
  showPieDownloadMenu.value = false
}

function togglePieDownloadMenu() {
  showPieDownloadMenu.value = !showPieDownloadMenu.value
  showLineDownloadMenu.value = false
}

// 点击外部关闭下载菜单
function closeDownloadMenus() {
  showLineDownloadMenu.value = false
  showPieDownloadMenu.value = false
}

// 导出图片
async function exportLineImage() {
  const el = document.getElementById('line-chart')
  if (!el) return
  const canvas = await html2canvas(el, { scale: 2, useCORS: true, allowTaint: true })
  const link = document.createElement('a')
  link.download = '情绪波动趋势.png'
  link.href = canvas.toDataURL()
  link.click()
  closeDownloadMenus()
}

async function exportPieImage() {
  const el = document.getElementById('pie-chart')
  if (!el) return
  const canvas = await html2canvas(el, { scale: 2, useCORS: true, allowTaint: true })
  const link = document.createElement('a')
  link.download = '情绪分布比例.png'
  link.href = canvas.toDataURL()
  link.click()
  closeDownloadMenus()
}

// 导出PDF
async function exportLinePDF() {
  const el = document.getElementById('line-chart')
  if (!el) return
  
  try {
    const canvas = await html2canvas(el, { scale: 2, useCORS: true, allowTaint: true })
    const imgData = canvas.toDataURL('image/png')
    const pdf = new jsPDF('p', 'mm', 'a4')
    const imgWidth = 180
    const imgHeight = (canvas.height * imgWidth) / canvas.width
    
    // 居中显示
    const x = (210 - imgWidth) / 2
    const y = (297 - imgHeight) / 2
    
    pdf.addImage(imgData, 'PNG', x, y, imgWidth, imgHeight)
    pdf.save('情绪波动趋势.pdf')
    closeDownloadMenus()
  } catch (error) {
    console.error('导出PDF失败:', error)
    alert('导出失败，请重试')
  }
}

async function exportPiePDF() {
  const el = document.getElementById('pie-chart')
  if (!el) return
  
  try {
    const canvas = await html2canvas(el, { scale: 2, useCORS: true, allowTaint: true })
    const imgData = canvas.toDataURL('image/png')
    const pdf = new jsPDF('p', 'mm', 'a4')
    const imgWidth = 180
    const imgHeight = (canvas.height * imgWidth) / canvas.width
    
    // 居中显示
    const x = (210 - imgWidth) / 2
    const y = (297 - imgHeight) / 2
    
    pdf.addImage(imgData, 'PNG', x, y, imgWidth, imgHeight)
    pdf.save('情绪分布比例.pdf')
    closeDownloadMenus()
  } catch (error) {
    console.error('导出PDF失败:', error)
    alert('导出失败，请重试')
  }
}

// 放大弹窗渲染大图
watch(showLineDialog, async (v) => {
  if (v) {
    await nextTick()
    renderLineChart('line-chart-big', true)
  }
})
watch(showPieDialog, async (v) => {
  if (v) {
    await nextTick()
    renderPieChart('pie-chart-big', true)
  }
})

onMounted(() => {
  // 初始化日期范围
  updateDateRange()
  loadCharts()

  // 监听窗口大小变化，重新调整图表
  window.addEventListener('resize', () => {
    if (lineChart.value) lineChart.value.resize()
    if (pieChart.value) pieChart.value.resize()
  })

  // 监听点击外部关闭下载菜单
  document.addEventListener('click', (e) => {
    if (!e.target.closest('.download-dropdown')) {
      closeDownloadMenus()
    }
  })
})

watch([startDate, endDate, selectedTimeRange], () => {
  loadCharts()
})
</script>
<style scoped>
.analysis-bg { min-height: 100vh; padding: 20px; display: flex; justify-content: center; align-items: flex-start; background: rgba(255,255,255,0.85) !important; }
.analysis-card { background: rgba(255, 255, 255, 0.95); border-radius: 20px; padding: 30px; width: 90%; max-width: 1200px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04); backdrop-filter: blur(10px); }
.analysis-title { font-size: 32px; font-weight: bold; text-align: center; color: #333; margin-bottom: 10px; background: linear-gradient(45deg, #667eea, #764ba2); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
.analysis-desc { text-align: center; color: #666; font-size: 16px; margin-bottom: 18px; }
.time-select-bar { display: flex; align-items: center; gap: 10px; margin-bottom: 18px; }
.charts-container { display: grid; grid-template-columns: 1fr 1fr; gap: 30px; margin-bottom: 30px; }
.chart-section { background: rgba(255,255,255,0.95) !important; border-radius: 18px; box-shadow: 0 2px 8px rgba(0,0,0,0.04); border: 1.5px solid #e0e7ef; padding: 28px 18px 18px 18px; position: relative; transition: border 0.3s; }
.card-hoverable { border: 2px solid #e0e7ef; transition: border 0.3s; }
.card-hoverable.card-active { border: 2.5px solid #3b82f6; box-shadow: 0 0 0 2px #a5d8ff; }
.chart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.chart-title { font-size: 18px; font-weight: bold; color: #333; }
.chart-actions { display: flex; gap: 8px; }
.chart-btn { background: #f3f4f6; border: none; border-radius: 6px; padding: 4px 12px; font-size: 13px; cursor: pointer; transition: background 0.2s; }
.chart-btn:hover { background: #e0e7ef; }

.download-dropdown { position: relative; }
.download-btn { position: relative; }
.download-menu { position: absolute; top: 100%; right: 0; background: white; border: 1px solid #e0e7ef; border-radius: 6px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); z-index: 1000; min-width: 80px; }
.download-option { display: block; width: 100%; padding: 8px 12px; border: none; background: none; text-align: left; cursor: pointer; font-size: 13px; color: #333; transition: background 0.2s; }
.download-option:hover { background: #f3f4f6; }
.download-option:first-child { border-radius: 6px 6px 0 0; }
.download-option:last-child { border-radius: 0 0 6px 6px; }
.chart-box { width: 100%; height: 300px; border-radius: 10px; background: white; }
.dominant-emotion-bar { margin-top: 18px; text-align: center; font-size: 16px; background: none; border-radius: 10px; padding: 0; box-shadow: none; }
.dominant-emotion-bar .dominant-emotion-desc { margin-top: 6px; color: #666; font-size: 14px; }
.ai-analysis-4 { display: flex; gap: 24px; margin-top: 18px; }
.ai-card { flex: 1; background: #fff; border-radius: 14px; box-shadow: 0 2px 8px rgba(0,0,0,0.04); border: 2px solid #e0e7ef; padding: 18px 16px; transition: border 0.3s; }
.ai-card.card-active { border: 2.5px solid #f59e42; box-shadow: 0 0 0 2px #ffe0b2; }
.ai-point-title { font-weight: bold; font-size: 15px; margin-bottom: 8px; color: #f59e42; }
.ai-point-content { font-size: 14px; color: #333; }
.dialog-mask { position: fixed; left: 0; top: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.25); z-index: 9999; display: flex; align-items: center; justify-content: center; }
.dialog-content { background: #fff; border-radius: 16px; padding: 24px; box-shadow: 0 4px 24px rgba(0,0,0,0.12); }
.chart-box-big { width: 600px; height: 400px; background: #fff; border-radius: 12px; }
.empty-state {
  text-align: center;
  color: #999;
  padding: 60px 20px;
  background: rgba(255,255,255,0.8);
  border-radius: 10px;
  border: 2px dashed #ddd;
  margin: 20px 0;
  font-size: 16px;
}
@media (max-width: 900px) { .charts-container, .ai-analysis-4 { flex-direction: column; display: flex; gap: 18px; } .chart-box-big { width: 95vw; height: 50vw; min-width: 260px; min-height: 180px; } }
</style>

<template>
  <div class="diary-bg">
    <div class="diary-card">
      <div v-if="!uid" class="empty-state">请先登录</div>
      <template v-else>
        <!-- 顶部导航按钮 -->
        <div class="nav-buttons">
          <button class="nav-btn nav-btn-primary" @click="goEdit()">
            <span class="btn-icon">✏️</span>
            新增日记
          </button>
          <button class="nav-btn nav-btn-search" @click="showSearch = !showSearch">
            <span class="btn-icon">🔍</span>
            搜索日记
          </button>
          <button class="nav-btn nav-btn-secondary" @click="showMyDiaries = !showMyDiaries">
            <span class="btn-icon">📖</span>
            我的日记
          </button>
        </div>
        
        <div class="nav-separator"></div>

        <!-- 页面标题 -->
        <div class="page-header">
          <span class="page-icon">📖</span>
          <h2 class="page-title">我的日记</h2>
          <span class="page-heart">❤️</span>
        </div>

        <!-- 搜索区域 -->
        <div v-if="showSearch" class="search-section">
          <div class="search-container">
            <div class="search-title">
              <span class="search-icon">🔍</span>
              搜索日记
            </div>
            <div class="search-inputs">
              <div class="input-group">
                <el-date-picker
                  v-model="searchDate"
                  type="date"
                  placeholder="选择日期"
                  clearable
                  :editable="false"
                  :close-on-select="true"
                  class="search-date-picker"
                />
                <span class="input-icon">📅</span>
              </div>
              <div class="input-group">
                <span class="input-icon">📝</span>
                <input type="text" placeholder="关键词" class="search-input" v-model="searchKeyword" />
              </div>
              <button class="search-btn" @click="performSearch">搜索</button>
            </div>
            <span class="search-heart">❤️</span>
          </div>
        </div>

        <!-- 状态筛选 -->
        <div class="status-filter">
          <button 
            class="status-btn" 
            :class="{ active: currentStatus === 'all' }"
            @click="filterByStatus('all')"
          >
            全部
          </button>
          <button 
            class="status-btn" 
            :class="{ active: currentStatus === 'published' }"
            @click="filterByStatus('published')"
          >
            已发布
          </button>
          <button 
            class="status-btn" 
            :class="{ active: currentStatus === 'draft' }"
            @click="filterByStatus('draft')"
          >
            草稿箱
          </button>
        </div>

        <!-- 日记列表 -->
        <div class="diary-list">
          <div v-if="Array.isArray(diaries) && diaries.length > 0">
            <div v-for="(diary, index) in diaries" :key="diary.diaryId" class="diary-item">
              <div class="diary-header">
                <h3 class="diary-title" @click="viewDiary(diary)">{{ diary.title }}</h3>
                <div class="diary-status">
                  <span v-if="diary.status === 'draft'" class="status-badge status-draft">草稿</span>
                  <span v-else-if="diary.status === 'published'" class="status-badge status-published">已发布</span>
                  <span class="diary-heart">❤️</span>
                </div>
              </div>
              <div class="diary-meta">
                <span class="meta-icon">📅</span>
                <span class="meta-date">{{ formatDate(diary.createTime) }}</span>
              </div>
              <div class="diary-emotion">
                <span class="emotion-icon">😊</span>
                <span class="emotion-text">情绪: {{ getEmotionText(diary) }}</span>
              </div>
              <div class="diary-tags" v-if="Array.isArray(diary.tags) && diary.tags.length">
                <span class="tag" v-for="(tag, idx) in diary.tags" :key="idx">
                  <span class="tag-icon">🏷️</span>
                  {{ tag }}
                </span>
              </div>
              <p class="diary-content" @click="viewDiary(diary)">{{ typeof diary.content === 'string' ? diary.content.substring(0, 50) : '' }}...</p>
              <div class="diary-footer">
                <div class="diary-actions" v-if="isAuthor(diary)">
                  <button class="action-btn edit-btn" @click="editDiary(diary)">编辑</button>
                  <button class="action-btn delete-btn" @click="deleteDiary(diary.diaryId)">删除</button>
                </div>
                <span class="diary-heart">❤️</span>
              </div>
            </div>
          </div>
          <div v-else class="empty-state">
            <div class="empty-icon">📖</div>
            <p>暂无日记数据</p>
            <p class="empty-hint">开始写下你的第一篇日记吧</p>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import request from '@/utils/request'
import { ElMessage, ElMessageBox } from 'element-plus'
import dayjs from 'dayjs'

const router = useRouter()
const uid = window.sessionStorage.getItem('uid')
const diaries = ref([])
const tags = ref([])
const selectedTag = ref(null)
const selectedDate = ref(null)

const showSearch = ref(false)
const showMyDiaries = ref(false)
const searchDate = ref('')
const searchKeyword = ref('')
const currentStatus = ref('all')
const filteredDiaries = ref([])

function resetFiltersExceptTab() {
  selectedTag.value = null;
  selectedDate.value = null;
}

function goEdit() { router.push('/user/diary/edit') }
function editDiary(diary) { router.push(`/user/diary/edit/${diary.diaryId}`) }
function viewDiary(diary) { router.push(`/user/diary/detail/${diary.diaryId}`) }

async function loadTags() {
  const res = await request.get('/api/tag')
  console.log('标签接口返回', res.data)
  tags.value = Array.isArray(res.data.data) ? res.data.data : []
  console.log('标签数据', tags.value)
}

async function loadDiaries() {
  if (!uid) {
    diaries.value = []
    return
  }
  
  try {
    const params = {}
    
    if (currentStatus.value === 'draft') {
      params.status = 'draft'
      params.targetUserId = uid
    } else if (currentStatus.value === 'published') {
      params.status = 'published'
    } else {
      // 全部：获取已发布的日记和当前用户的草稿
      const pubParams = { status: 'published' }
      console.log('[全部] 已发布请求参数:', pubParams)
      const pubRes = await request.get('/api/diary', { params: pubParams })
      console.log('[全部] 已发布返回:', pubRes.data)
      let allList = (pubRes.data.code === 200 && Array.isArray(pubRes.data.data)) ? pubRes.data.data : []
      
      const draftParams = { status: 'draft', targetUserId: uid }
      console.log('[全部] 草稿请求参数:', draftParams)
      const draftRes = await request.get('/api/diary', { params: draftParams })
      console.log('[全部] 草稿返回:', draftRes.data)
      let draftList = (draftRes.data.code === 200 && Array.isArray(draftRes.data.data)) ? draftRes.data.data : []
      
      // 合并并去重
      const allIds = new Set()
      const merged = []
      for (const d of allList.concat(draftList)) {
        if (!allIds.has(d.diaryId)) {
          allIds.add(d.diaryId)
          merged.push(d)
        }
      }
      console.log('[全部] 合并后:', merged)
      diaries.value = merged
      return
    }
    
    console.log('加载日记参数:', params)
    const res = await request.get('/api/diary', { params })
    
    if (res.data.code === 200) {
      diaries.value = Array.isArray(res.data.data) ? res.data.data : []
    } else {
      diaries.value = []
      console.error('加载日记失败:', res.data.message)
    }
  } catch (error) {
    console.error('加载日记失败:', error)
    diaries.value = []
  }
}

function onTabChange() {
  resetFiltersExceptTab();
  loadDiaries();
}

function onDateChange() {
  loadDiaries();
}

function onTagChange() {
  loadDiaries();
}

function formatDate(date) {
  if (!date) return '';
  return dayjs(date).format('YYYY-MM-DD HH:mm');
}

function isAuthor(diary) {
  return diary.userId == uid;
}

function getEmotionText(diary) {
  // 根据日记内容或标签判断情绪
  if (diary.tags && diary.tags.length > 0) {
    const emotionTags = diary.tags.filter(tag => 
      ['开心', '难过', '焦虑', '兴奋', '平静'].includes(tag)
    )
    return emotionTags.length > 0 ? emotionTags[0] : '平静'
  }
  return '平静'
}

// 搜索功能
async function performSearch() {
  try {
    const params = {
      status: currentStatus.value === 'all' ? undefined : currentStatus.value,
      targetUserId: uid
    }
    
    if (searchDate.value) {
      // 使用dayjs格式化日期为 YYYY-MM-DD 格式
      params.date = dayjs(searchDate.value).format('YYYY-MM-DD')
    }
    
    if (searchKeyword.value && searchKeyword.value.trim()) {
      params.keyword = searchKeyword.value.trim()
    }
    
    console.log('搜索参数:', params)
    const res = await request.get('/api/diary/search', { params })
    
    if (res.data.code === 200) {
      diaries.value = Array.isArray(res.data.data) ? res.data.data : []
      ElMessage.success('搜索完成')
    } else {
      ElMessage.error(res.data.message || '搜索失败')
    }
  } catch (error) {
    console.error('搜索失败:', error)
    ElMessage.error('搜索失败')
  }
}

// 状态筛选
function filterByStatus(status) {
  currentStatus.value = status
  loadDiaries()
}



function getMediaList(diary) {
  return Array.isArray(diary.media) ? diary.media : [];
}

async function deleteDiary(diaryId) {
  try {
    await ElMessageBox.confirm('确定要删除这篇日记吗？', '确认删除', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });
    
    const res = await request.delete(`/api/diary/${diaryId}`);
    if (res.data.code === 200) {
      ElMessage.success('删除成功');
      loadDiaries();
    } else {
      ElMessage.error(res.data.message || '删除失败');
    }
  } catch (e) {
    if (e !== 'cancel') {
      console.error('Error deleting diary:', e);
      ElMessage.error('删除失败');
    }
  }
}

onMounted(() => {
  loadTags();
  loadDiaries();
})
</script>

<style scoped>
.diary-bg {
  min-height: 100vh;
  background: linear-gradient(135deg, #ffeef8 0%, #fff5f5 100%) !important;
  padding: 20px;
}

.diary-card {
  background: rgba(255, 255, 255, 0.95) !important;
  border-radius: 20px;
  box-shadow: 0 8px 32px rgba(255, 182, 193, 0.15);
  padding: 30px;
  margin: 0 auto;
  max-width: 1200px;
  border: 2px dashed rgba(255, 182, 193, 0.3);
}

.book-cover {
  background: transparent !important;
  text-align: center;
  margin-bottom: 30px;
  position: relative;
}

.book-title {
  font-size: 2.5rem;
  color: #2c3e50;
  margin: 0;
  font-weight: bold;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
}

.book-spine {
  width: 60px;
  height: 4px;
  background: linear-gradient(90deg, #e74c3c, #f39c12, #f1c40f, #27ae60, #3498db, #9b59b6);
  margin: 20px auto;
  border-radius: 2px;
}

/* 顶部导航按钮 */
.nav-buttons {
  display: flex;
  justify-content: space-between;
  margin-bottom: 20px;
  gap: 15px;
}

.nav-btn {
  flex: 1;
  padding: 12px 20px;
  border: none;
  border-radius: 15px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.nav-btn-primary {
  background: linear-gradient(135deg, #ffb6c1, #ffc0cb);
  color: white;
}

.nav-btn-search {
  background: linear-gradient(135deg, #ffd700, #ffa500);
  color: white;
}

.nav-btn-secondary {
  background: linear-gradient(135deg, #87ceeb, #98d8e8);
  color: white;
}

.nav-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.15);
}

.nav-separator {
  height: 2px;
  background: linear-gradient(90deg, transparent, rgba(255, 182, 193, 0.5), transparent);
  margin: 20px 0;
}

/* 页面标题 */
.page-header {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 30px;
  gap: 15px;
}

.page-icon {
  font-size: 24px;
}

.page-title {
  font-size: 28px;
  font-weight: bold;
  color: #ff69b4;
  margin: 0;
}

.page-heart {
  font-size: 20px;
}

/* 搜索区域 */
.search-section {
  margin-bottom: 30px;
}

.search-container {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 15px;
  padding: 20px;
  border: 2px dashed rgba(255, 182, 193, 0.3);
  position: relative;
}

.search-title {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 18px;
  font-weight: 600;
  color: #87ceeb;
  margin-bottom: 20px;
}

.search-inputs {
  display: flex;
  gap: 15px;
  align-items: center;
}

.input-group {
  flex: 1;
  position: relative;
  display: flex;
  align-items: center;
}

.search-input {
  width: 100%;
  padding: 12px 15px;
  border: 2px dashed rgba(255, 182, 193, 0.3);
  border-radius: 10px;
  font-size: 14px;
  background: rgba(255, 255, 255, 0.8);
  transition: all 0.3s ease;
}

.search-input:focus {
  outline: none;
  border-color: #ffb6c1;
  box-shadow: 0 0 0 3px rgba(255, 182, 193, 0.1);
}

.input-icon {
  position: absolute;
  right: 12px;
  font-size: 16px;
  color: #ffb6c1;
}

.search-date-picker {
  width: 100%;
}

.search-date-picker .el-input__wrapper {
  border: 2px dashed rgba(255, 182, 193, 0.3);
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.8);
}

.search-date-picker .el-input__wrapper:hover {
  border-color: #ffb6c1;
}

.search-date-picker .el-input__wrapper.is-focus {
  border-color: #ffb6c1;
  box-shadow: 0 0 0 3px rgba(255, 182, 193, 0.1);
}

.search-btn {
  padding: 12px 20px;
  background: linear-gradient(135deg, #ffd700, #ffa500);
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.search-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(255, 215, 0, 0.3);
}

.search-heart {
  position: absolute;
  top: 15px;
  right: 15px;
  font-size: 18px;
}

/* 状态筛选 */
.status-filter {
  display: flex;
  gap: 15px;
  margin-bottom: 20px;
  justify-content: center;
}

.status-btn {
  padding: 10px 20px;
  border: 2px solid rgba(255, 182, 193, 0.3);
  border-radius: 15px;
  background: rgba(255, 255, 255, 0.8);
  color: #666;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.status-btn:hover {
  border-color: #ffb6c1;
  background: rgba(255, 182, 193, 0.1);
}

.status-btn.active {
  background: linear-gradient(135deg, #ffb6c1, #ff69b4);
  color: white;
  border-color: #ff69b4;
  box-shadow: 0 4px 12px rgba(255, 182, 193, 0.3);
}

.diary-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.diary-item {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 15px;
  padding: 20px;
  border: 2px dashed rgba(255, 182, 193, 0.3);
  transition: all 0.3s ease;
  position: relative;
}

.diary-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(255, 182, 193, 0.2);
  border-color: rgba(255, 182, 193, 0.5);
}

.diary-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.diary-title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin: 0;
  cursor: pointer;
  transition: color 0.3s ease;
}

.diary-title:hover {
  color: #ff69b4;
}

.diary-heart {
  font-size: 16px;
}

.diary-status {
  display: flex;
  align-items: center;
  gap: 8px;
}

.status-badge {
  padding: 4px 8px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 600;
}

.status-draft {
  background: rgba(255, 165, 0, 0.2);
  color: #ff8c00;
  border: 1px solid rgba(255, 165, 0, 0.3);
}

.status-published {
  background: rgba(50, 205, 50, 0.2);
  color: #32cd32;
  border: 1px solid rgba(50, 205, 50, 0.3);
}

.diary-actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  padding: 6px 12px;
  border: none;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.edit-btn {
  background: linear-gradient(135deg, #87ceeb, #98d8e8);
  color: white;
}

.edit-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(135, 206, 235, 0.3);
}

.delete-btn {
  background: linear-gradient(135deg, #ff6b6b, #ff5252);
  color: white;
}

.delete-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(255, 107, 107, 0.3);
}

.diary-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
  font-size: 14px;
  color: #666;
}

.meta-icon {
  font-size: 14px;
}

.meta-date {
  font-weight: 500;
}

.diary-emotion {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
  font-size: 14px;
  color: #666;
}

.emotion-icon {
  font-size: 16px;
}

.emotion-text {
  font-weight: 500;
}

.diary-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 12px;
}

.tag {
  background: rgba(255, 182, 193, 0.2);
  color: #ff69b4;
  border-radius: 12px;
  padding: 4px 12px;
  font-size: 12px;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 4px;
  border: 1px solid rgba(255, 182, 193, 0.3);
}

.tag-icon {
  font-size: 12px;
}

.media-preview {
  display: flex;
  gap: 10px;
  margin: 15px 0;
  flex-wrap: wrap;
}

.media-thumb {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 8px;
  border: 2px solid #ecf0f1;
}

.diary-content {
  color: #333;
  line-height: 1.6;
  margin: 12px 0;
  cursor: pointer;
  transition: color 0.3s ease;
  font-size: 14px;
}

.diary-content:hover {
  color: #ff69b4;
}

.diary-footer {
  display: flex;
  justify-content: flex-end;
  margin-top: 10px;
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: #999;
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 20px;
  opacity: 0.5;
}

.empty-hint {
  color: #ccc;
  font-size: 14px;
  margin-top: 10px;
}

.btn-icon {
  font-size: 16px;
}
</style>


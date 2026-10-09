<template>
  <div class="detail-bg">
    <div class="detail-card">
      <h2 class="detail-title">{{ diary.title }}</h2>
      <div class="detail-meta">
        <span>作者：{{ authorName }}</span>
        <span style="margin-left: 16px;">{{ formatTime(diary.createTime) }}</span>
      </div>
      <div class="detail-content">{{ diary.content }}</div>
      <div class="media-list">
        <div v-for="media in diary.media" :key="media.mediaId" class="media-item">
          <img v-if="media.mediaType==='image'" :src="getFullUrl(media.mediaUrl)" class="media-img" />
          <video v-else-if="media.mediaType==='video'" :src="getFullUrl(media.mediaUrl)" controls class="media-video" />
          <audio v-else-if="media.mediaType==='audio'" :src="getFullUrl(media.mediaUrl)" controls class="media-audio" />
        </div>
      </div>
      <div class="tags">
        <span v-for="(tag, index) in diary.tags" :key="index" class="tag">{{ tag }}</span>
      </div>
      
      <!-- 只有日记作者才能看到编辑和删除按钮 -->
      <div v-if="isAuthor" class="action-buttons">
        <button class="edit-btn" @click="goEdit">编辑日记</button>
        <button class="delete-btn" @click="deleteDiary">删除日记</button>
      </div>
      
      <button class="analysis-btn" @click="goAnalysis">情绪分析</button>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import request from '@/utils/request'
import { ElMessage, ElMessageBox } from 'element-plus'
import dayjs from 'dayjs'

const route = useRoute()
const router = useRouter()
const diary = ref({ title: '', content: '', createTime: '', media: [], tags: [], userId: null })

// 判断是否为日记作者
const isAuthor = computed(() => {
  const currentUserId = window.sessionStorage.getItem('uid')
  return currentUserId && diary.value.userId && currentUserId === diary.value.userId.toString()
})

// 作者名显示
const authorName = computed(() => {
  const currentUserId = window.sessionStorage.getItem('uid')
  if (currentUserId && diary.value.userId && currentUserId === diary.value.userId.toString()) {
    return '我'
  }
  if (diary.value.nickname) return diary.value.nickname
  return `用户ID:${diary.value.userId}`
})

// 时间格式化
function formatTime(time) {
  if (!time) return ''
  const t = typeof time === 'number' ? time : Number(time)
  return dayjs(t).format('YYYY-MM-DD HH:mm:ss')
}

// 处理媒体文件URL
function getFullUrl(url) {
  if (!url) return '';
  if (url.startsWith('http')) return url;
  const fullUrl = 'http://localhost:8081' + url;
  console.log('Media URL:', url, '-> Full URL:', fullUrl);
  return fullUrl;
}

async function loadDiary() {
  try {
  const res = await request.get(`/api/diary/${route.params.id}`)
    diary.value = res.data.data || { title: '', content: '', createTime: '', media: [], tags: [], userId: null }
    // 添加调试信息
    console.log('Loaded diary:', diary.value)
    console.log('Media files:', diary.value.media)
    console.log('Media count:', diary.value.media ? diary.value.media.length : 0)
  } catch (error) {
    console.error('Error loading diary:', error)
    ElMessage.error('加载日记失败')
  }
}

function goAnalysis() { 
  router.push('/user/analysis') 
}

function goEdit() {
  router.push(`/user/diary/edit/${route.params.id}`)
}

async function deleteDiary() {
  try {
    await ElMessageBox.confirm('确定要删除这篇日记吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await request.delete(`/api/diary/${route.params.id}`)
    ElMessage.success('删除成功')
    router.push('/user/diary')
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

onMounted(() => { 
  loadDiary() 
})
</script>
<style scoped>
.detail-bg {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  padding: 40px 0;
  background: rgba(255,255,255,0.85) !important;
}
.detail-card {
  background: rgba(255,255,255,0.95) !important;
  border-radius: 18px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  padding: 36px 32px 32px 32px;
  width: 600px;
  max-width: 95vw;
  display: flex;
  flex-direction: column;
  gap: 18px;
}
.detail-title {
  font-size: 28px;
  font-weight: bold;
  color: #7ec6e6;
  margin-bottom: 10px;
  letter-spacing: 2px;
  text-align: center;
}
.detail-meta {
  font-size: 14px;
  color: #999;
  margin-bottom: 10px;
  text-align: center;
}
.detail-content {
  font-size: 16px;
  color: #333;
  margin-bottom: 10px;
  white-space: pre-line;
}
.media-list {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 10px;
}
.media-item {
  display: flex;
  flex-direction: column;
  align-items: center;
}
.media-img {
  max-width: 200px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(126,198,230,0.10);
}
.media-video {
  max-width: 200px;
  border-radius: 8px;
  margin-top: 6px;
}
.media-audio {
  width: 200px;
  margin-top: 6px;
}
.tags {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  margin-bottom: 10px;
  justify-content: center;
}
.tag {
  background: #7ec6e6;
  color: #fff;
  padding: 4px 14px;
  border-radius: 14px;
  font-size: 14px;
}
.action-buttons {
  display: flex;
  gap: 12px;
  justify-content: center;
  margin-bottom: 10px;
}
.edit-btn, .delete-btn {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.2s;
}
.edit-btn {
  background: #7ec6e6;
  color: white;
}
.edit-btn:hover {
  background: #6bb5d5;
}
.delete-btn {
  background: #f56c6c;
  color: white;
}
.delete-btn:hover {
  background: #e55a5a;
}
.analysis-btn {
  width: 100%;
  background: linear-gradient(90deg, #7ec6e6, #f7cac9);
  color: #fff;
  border: none;
  border-radius: 10px;
  padding: 14px 0;
  font-size: 18px;
  font-weight: bold;
  box-shadow: 0 2px 8px rgba(126,198,230,0.15);
  margin-top: 10px;
  cursor: pointer;
  transition: background 0.2s;
}
.analysis-btn:hover {
  background: linear-gradient(90deg, #f7cac9, #7ec6e6);
}
</style> 
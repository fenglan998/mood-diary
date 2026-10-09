<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import request from '@/utils/request'
import { ElMessage } from 'element-plus'
// 整个应用的框架，所有页面都在这里面显示
const unreadReminders = ref([])
const showCapsuleReminder = ref(false)
const showImagePreview = ref(false)
const previewImageUrl = ref('')
let reminderTimer = null
let reminderCheckTimer = null

// 格式化时间显示
function formatTime(timestamp) {
  if (!timestamp) return '未知时间'
  const date = new Date(timestamp)
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  return `${year}-${month}-${day} ${hours}:${minutes}`
}

// 启动定时检查提醒
function startReminderCheck() {
  // 每3分钟检查一次提醒
  reminderCheckTimer = setInterval(() => {
    loadUnreadReminders()
  }, 3 * 60 * 1000)
}

// 停止定时检查
function stopReminderCheck() {
  if (reminderCheckTimer) {
    clearInterval(reminderCheckTimer)
    reminderCheckTimer = null
  }
}

// 页面激活时检查提醒
function handlePageVisibilityChange() {
  if (!document.hidden) {
    console.log('页面激活，检查提醒')
    loadUnreadReminders()
  }
}

// 获取完整的媒体文件URL
function getFullUrl(filePath) {
  if (!filePath) return ''
  if (filePath.startsWith('http')) return filePath
  const fullUrl = `http://localhost:8081${filePath}`
  console.log('媒体文件URL:', { original: filePath, full: fullUrl })
  return fullUrl
}

// 获取媒体文件类型
function getMediaType(filePath) {
  if (!filePath) return ''
  const lowerPath = filePath.toLowerCase()
  if (lowerPath.match(/\.(jpg|jpeg|png|gif|webp)$/)) return 'image'
  if (lowerPath.match(/\.(mp3|wav|ogg|aac|m4a|nvm|ncm)$/)) return 'audio' // 添加ncm支持在线播放
  if (lowerPath.match(/\.(mp4|avi|mov|wmv|flv)$/)) return 'video'
  return 'other'
}

// 打开图片预览
function openImagePreview(imageUrl) {
  previewImageUrl.value = imageUrl
  showImagePreview.value = true
}

// 关闭图片预览
function closeImagePreview() {
  showImagePreview.value = false
  previewImageUrl.value = ''
}

// 处理图片加载错误
function handleImageError(event) {
  console.error('图片加载失败:', event.target.src)
  event.target.style.display = 'none'
  event.target.nextElementSibling.textContent = '图片加载失败'
}

// 处理音频加载错误
function handleAudioError(event) {
  console.error('音频加载失败:', event.target.src)
  ElMessage.error('音频文件无法播放')
}

// 处理视频加载错误
function handleVideoError(event) {
  console.error('视频加载失败:', event.target.src)
  ElMessage.error('视频文件无法播放')
}

// 播放音频
function playAudio(audioUrl) {
  console.log('播放音频:', audioUrl)
  // 可以在这里添加音频播放逻辑
}

// 播放视频
function playVideo(videoUrl) {
  console.log('播放视频:', videoUrl)
  // 可以在这里添加视频播放逻辑
}

// 获取未读提醒
async function loadUnreadReminders() {
  try {
    const res = await request.get('/api/capsules/reminders/unread')
    if (res.data.code === 200) {
      unreadReminders.value = res.data.data || []
      showCapsuleReminder.value = unreadReminders.value.length > 0
      
      // 如果有新提醒，显示通知
      if (unreadReminders.value.length > 0) {
        console.log('发现新的情绪胶囊提醒:', unreadReminders.value.length, '个')
        // 可以在这里添加浏览器通知
        if ('Notification' in window && Notification.permission === 'granted') {
          new Notification('情绪胶囊提醒', {
            body: `您有 ${unreadReminders.value.length} 个情绪胶囊已到开启时间`,
            icon: '/src/static/imgs/back.png'
          })
        }
      }
    }
  } catch (e) {
    console.error('加载提醒失败:', e)
  }
}

async function markRead(capsuleId) {
  await request.post(`/api/capsules/reminders/read/${capsuleId}`)
  unreadReminders.value = unreadReminders.value.filter(r => r.capsuleId !== capsuleId)
  if (unreadReminders.value.length === 0) showCapsuleReminder.value = false
  console.log('已读后showCapsuleReminder:', showCapsuleReminder.value)
}

onMounted(() => {
  loadUnreadReminders()
  reminderTimer = setInterval(loadUnreadReminders, 60 * 1000) // 每分钟轮询一次
  startReminderCheck()
  document.addEventListener('visibilitychange', handlePageVisibilityChange)
})

onUnmounted(() => {
  // 清理定时器和事件监听器
  if (reminderTimer) {
    clearInterval(reminderTimer)
  }
  stopReminderCheck()
  document.removeEventListener('visibilitychange', handlePageVisibilityChange)
})
</script>

<template>
  <div id="app" class="global-bg">
    <router-view></router-view>
    
    <!-- 情绪胶囊提醒弹窗 -->
    <el-dialog v-model="showCapsuleReminder" title="情绪胶囊提醒" width="600px" :close-on-click-modal="false">
      <div v-for="reminder in unreadReminders" :key="reminder.capsuleId" class="reminder-item">
        <div class="reminder-time">开启时间：{{ formatTime(reminder.openTime) }}</div>
        <div class="reminder-content">内容：{{ reminder.content ? reminder.content.slice(0, 50) : '（无内容）' }}</div>
        
        <!-- 媒体文件预览 -->
        <div v-if="reminder.media && reminder.media.length > 0" class="media-preview">
          <div class="media-title">附件：</div>
          <div class="media-list">
            <div v-for="(media, index) in reminder.media" :key="index" class="media-item">
              <!-- 调试信息 -->
              <div class="debug-info" style="font-size: 10px; color: #999; margin-bottom: 5px;">
                调试: {{ media.mediaUrl }} | 类型: {{ getMediaType(media.mediaUrl) }}
              </div>
              
              <!-- 图片预览 -->
              <div v-if="getMediaType(media.mediaUrl) === 'image'" class="media-image-container">
                <img 
                  :src="getFullUrl(media.mediaUrl)" 
                  class="media-image"
                  @click="openImagePreview(getFullUrl(media.mediaUrl))"
                  alt="图片预览"
                  @error="handleImageError"
                />
                <div class="image-hint">点击查看大图</div>
              </div>
              
              <!-- 音频预览 -->
              <div v-else-if="getMediaType(media.mediaUrl) === 'audio'" class="media-audio">
                <div class="media-header">
                  <i class="el-icon-headset"></i>
                  <span>音频文件</span>
                </div>
                <div class="audio-debug" style="font-size: 10px; color: #999; margin-bottom: 5px;">
                  音频URL: {{ getFullUrl(media.mediaUrl) }}
                </div>
                <div class="audio-controls">
                  <button @click="playAudio(getFullUrl(media.mediaUrl))" class="play-btn">
                    <i class="el-icon-video-play"></i> 播放
                  </button>
                <audio 
                  :src="getFullUrl(media.mediaUrl)" 
                  controls 
                  class="audio-player" 
                  preload="metadata" 
                  @error="handleAudioError"
                  @loadstart="() => console.log('音频开始加载:', getFullUrl(media.mediaUrl))"
                  @canplay="() => console.log('音频可以播放:', getFullUrl(media.mediaUrl))"
                  @loadeddata="() => console.log('音频数据加载完成:', getFullUrl(media.mediaUrl))"
                ></audio>
                </div>
              </div>
              
              <!-- 视频预览 -->
              <div v-else-if="getMediaType(media.mediaUrl) === 'video'" class="media-video">
                <div class="media-header">
                  <i class="el-icon-video-camera"></i>
                  <span>视频文件</span>
                </div>
                <div class="video-controls">
                  <button @click="playVideo(getFullUrl(media.mediaUrl))" class="play-btn">
                    <i class="el-icon-video-play"></i> 播放
                  </button>
                <video :src="getFullUrl(media.mediaUrl)" controls class="video-player" preload="metadata" @error="handleVideoError"></video>
                </div>
              </div>
              
              <!-- 其他文件 -->
              <div v-else class="media-other">
                <i class="el-icon-document"></i>
                <span>{{ media.mediaUrl.split('/').pop() }}</span>
                <a :href="getFullUrl(media.mediaUrl)" download style="margin-left:8px;color:#409eff;">下载</a>
              </div>
            </div>
          </div>
        </div>
        
        <el-button size="small" type="primary" @click="markRead(reminder.capsuleId)" class="mark-read-btn">
          我知道了
        </el-button>
      </div>
      <div v-if="!unreadReminders.length">无未读提醒（调试）</div>
    </el-dialog>
    
    <!-- 图片预览弹窗 -->
    <el-dialog v-model="showImagePreview" title="图片预览" width="80%" :close-on-click-modal="true" @close="closeImagePreview">
      <div class="image-preview-container">
        <img :src="previewImageUrl" class="preview-image" alt="预览图片" />
      </div>
    </el-dialog>
  </div>
</template>

<style scoped>
.global-bg {
  min-height: 100vh;
  /* background: url('./static/imgs/back.png') no-repeat center center fixed; */
  /* background-size: cover; */
}

.reminder-item {
  margin-bottom: 20px;
  padding: 15px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  background-color: #fafafa;
}

.reminder-time {
  font-weight: bold;
  color: #409eff;
  margin-bottom: 8px;
}

.reminder-content {
  margin-bottom: 12px;
  color: #606266;
  line-height: 1.5;
}

.media-preview {
  margin-bottom: 12px;
}

.media-title {
  font-weight: bold;
  color: #606266;
  margin-bottom: 8px;
}

.media-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.media-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.media-image-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
}

.media-image {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 6px;
  cursor: pointer;
  border: 2px solid #dcdfe6;
  transition: all 0.3s ease;
}

.media-image:hover {
  transform: scale(1.05);
  border-color: #409eff;
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
}

.image-hint {
  font-size: 12px;
  color: #909399;
  text-align: center;
}

.media-audio, .media-video {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 12px;
  background-color: #f5f7fa;
  border-radius: 6px;
  border: 1px solid #e4e7ed;
}

.media-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: bold;
  color: #606266;
}

.media-other {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px;
  background: #f5f5f5;
  border-radius: 4px;
}

.audio-controls, .video-controls {
  margin-top: 8px;
}

.play-btn {
  background: #409eff;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 4px 8px;
  font-size: 12px;
  cursor: pointer;
  margin-bottom: 8px;
}

.play-btn:hover {
  background: #337ecc;
}

.audio-player, .video-player {
  width: 100%;
  max-width: 100%;
}

.audio-player {
  height: 40px;
}

.video-player {
  max-height: 200px;
}

.mark-read-btn {
  margin-top: 15px;
}

.image-preview-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

.preview-image {
  max-width: 100%;
  max-height: 80vh;
  object-fit: contain;
  border-radius: 8px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
}

.el-input {
  width: 180px;
}

:deep(.el-input__wrapper) {
  border: none;
}

/* 确保音频和视频播放器在弹窗中正常显示 */
:deep(.el-dialog__body) {
  max-height: 70vh;
  overflow-y: auto;
}
</style>

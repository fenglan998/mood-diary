<template>
  <div class="capsule-page">


  <!-- 云朵背景 -->
  <div class="cloud-bg" ref="cloudBg"></div>

  <!-- 粒子背景容器 -->
  <div id="particles-js"></div>

  <!-- 顶部标题区域 -->
  <div class="header">
    <div class="header-content">
      <h1>情绪胶囊</h1>
      <p class="subtitle">把心情藏进时光里</p>
      <p class="intro-text">记录此刻情绪，留给未来的自己</p>
        <div class="scroll-down" @click="scrollToContent">
        <div class="arrow"></div>
      </div>
    </div>
  </div>



  <!-- 漂浮胶囊 -->
  <div class="floating-capsule" ref="floatingCapsule">
    <div class="inner-glow"></div>
    <div class="inner-glow"></div>
    <div class="capsule-content"></div>
    <div class="envelope">
      <div class="texture"></div>
      <div class="seal"></div>
    </div>
  </div>

  <!-- 固定按钮 -->
    <button class="fixed-btn past-btn" @click="showCapsuleList" title="查看过往胶囊">
    <i class="bi bi-alarm"></i>
  </button>
    <button class="fixed-btn new-btn" @click="showCreateForm" title="新建胶囊">
    <i class="bi bi-plus-lg"></i>
  </button>

  <div class="container py-5">
    <!-- 创建胶囊表单 -->
      <div class="capsule-container" ref="createCapsuleContainer" v-show="showCreate">
        <h2 class="text-center mb-4">✉️ 创建情绪胶囊</h2>

        <form @submit.prevent="saveCapsule">
          <!-- 情绪选择 -->
          <div class="mb-4">
            <label for="emotion" class="form-label">当前情绪</label>
            <select class="form-select" id="emotion" v-model="currentEmotion" required>
              <option value="happy">😊 开心</option>
              <option value="sad">😢 悲伤</option>
              <option value="angry">😠 愤怒</option>
              <option value="anxious">😰 焦虑</option>
              <option value="excited">🤩 兴奋</option>
              <option value="peaceful">😌 平静</option>
              <option value="confused">😕 困惑</option>
              <option value="grateful">🥰 感恩</option>
          </select>
              </div>

          <!-- 想法输入 -->
          <div class="mb-3">
            <label for="thoughts" class="form-label">你的想法</label>
            <textarea class="form-control" id="thoughts" rows="3" placeholder="写下你此刻的想法..." v-model="thoughts" required></textarea>
        </div>

          <!-- 目标输入 -->
          <div class="mb-3">
            <label for="goals" class="form-label">未来目标</label>
            <textarea class="form-control" id="goals" rows="2" placeholder="写下你对未来的期望或目标..." v-model="goals"></textarea>
      </div>

          <!-- 媒体添加 -->
          <div class="mb-3">
            <label class="form-label">添加媒体</label>
            <div class="media-preview text-center" id="mediaPreview">
              <p v-if="mediaFiles.length === 0" class="text-muted">点击下方按钮添加照片或录音</p>
              <div v-else class="media-files">
                <div v-for="(file, index) in mediaFiles" :key="index" class="media-file">
                  <span>{{ file.name }}</span>
                  <button type="button" @click="removeFile(index)" class="remove-file">×</button>
                </div>
              </div>
            </div>
            <div class="d-flex gap-2">
              <button type="button" class="btn btn-outline-primary flex-grow-1" @click="triggerPhotoInput">
                <i class="bi bi-camera"></i> 添加照片
              </button>
              <button type="button" class="btn btn-outline-primary flex-grow-1" @click="triggerMediaInput">
                <i class="bi bi-camera-video"></i> 添加视频/音频
              </button>
              <input type="file" ref="photoInput" accept="image/*" style="display: none;" @change="handlePhotoChange">
              <input type="file" ref="mediaInput" accept="video/*,audio/*" style="display: none;" @change="handleMediaChange">
            </div>
      </div>

          <!-- 开启时间和提醒方式 -->
          <div class="row mb-3">
            <div class="col-md-6">
              <label for="openDate" class="form-label">开启时间</label>
              <input type="text" class="form-control" id="openDate" placeholder="选择开启日期和时间" v-model="openDate" required>
            </div>
            <div class="col-md-6">
              <label for="reminderType" class="form-label">提醒方式</label>
              <select class="form-select" id="reminderType" v-model="reminderType">
                <option value="app_notification">应用内通知</option>
                <option value="sms">短信</option>
              </select>
            </div>
      </div>

          <!-- 保存按钮 -->
          <div class="d-grid gap-3 mt-4">
            <button type="submit" class="btn btn-capsule" :disabled="isSaving">
              <span>{{ isSaving ? '保存中...' : '封存' }}</span>
              <span class="hover-text">准备好封装心情了吗？</span>
                    </button>
                  </div>
        </form>
          </div>

      <!-- 胶囊列表 -->
      <div class="capsule-container mt-5" ref="capsuleListContainer" v-show="showList">
        <h3 class="text-center mb-4">📫 我的情绪胶囊</h3>
        <div class="row" id="capsuleList">
          <div v-for="capsule in capsuleList" :key="capsule.id" class="col-md-6 col-lg-4 mb-4">
            <div class="capsule-card">
              <div class="capsule-header">
                <div class="emotion-badge">
                  <span class="emotion-emoji">{{ getEmotionEmoji(capsule.currentEmotion) }}</span>
                  <span class="emotion-text">{{ getEmotionText(capsule.currentEmotion) }}</span>
                    </div>
                <div class="capsule-status">
                  <span class="status-dot" :class="{ 'opened': capsule.opened }"></span>
                  {{ capsule.opened ? '已开启' : '等待开启' }}
            </div>
          </div>

              <!-- 未展开时显示的时间信息 -->
              <div class="capsule-time-preview" v-if="!capsule.showDetails">
                <div class="time-info">
                  <span class="time-icon">⏰</span>
                  <span class="time-text">{{ capsule.opened ? '已于' : '将在' }}{{ formatTime(capsule.openTime) }}{{ capsule.opened ? '开启' : '开启' }}</span>
        </div>
            </div>

              <div class="capsule-content" v-if="capsule.showDetails">
                <p class="content-text">{{ capsule.thoughts }}</p>
      </div>

              <div class="capsule-footer">
                <div class="time-info">
                  <span class="time-icon">⏰</span>
                  <span class="time-text">{{ capsule.opened ? '已于' : '将在' }}{{ formatTime(capsule.openTime) }}{{ capsule.opened ? '开启' : '开启' }}</span>
                </div>
                <div class="capsule-actions">
                  <button @click="toggleDetails(capsule)" class="details-btn" :title="capsule.showDetails ? '收起详情' : '查看详情'">
                    <i class="bi" :class="capsule.showDetails ? 'bi-chevron-up' : 'bi-chevron-down'"></i>
                  </button>
                  <button @click="deleteCapsule(capsule.capsuleId)" class="delete-btn">
                    <span class="delete-icon">🗑️</span>
          </button>
        </div>
      </div>

              <!-- 展开的详细信息 -->
              <div v-if="capsule.showDetails" class="capsule-details">
                <div class="detail-item">
                  <span class="detail-label">创建时间：</span>
                  <span class="detail-value">{{ formatDate(capsule.createTime) }}</span>
              </div>
                <div v-if="capsule.futureGoal" class="detail-item">
                  <span class="detail-label">未来目标：</span>
                  <span class="detail-value goals-text">{{ capsule.futureGoal }}</span>
                </div>
                <div v-if="capsule.media && capsule.media.length > 0" class="detail-item">
                  <span class="detail-label">媒体文件：</span>
                  <div class="media-list">
                    <div v-for="media in capsule.media" :key="media.mediaId" class="media-item" @click="previewMedia(media)">
                      <span class="media-icon">
                        <i v-if="getMediaType(media.mediaUrl) === 'image'" class="bi bi-image"></i>
                        <i v-else-if="getMediaType(media.mediaUrl) === 'video'" class="bi bi-camera-video"></i>
                        <i v-else-if="getMediaType(media.mediaUrl) === 'audio'" class="bi bi-music-note"></i>
                        <i v-else class="bi bi-file-earmark"></i>
                      </span>
                      <span class="media-name">{{ getMediaShortName(media.mediaUrl) }}</span>
                      <span class="media-preview-hint">点击预览</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        </div>
      </div>

        <!-- 底部星星背景 -->
    <div class="stars-bg" ref="starsBg"></div>

    <!-- 通知弹窗 -->
    <div v-if="showNotification" class="notification-overlay" @click="closeNotification">
      <div class="notification-modal" @click.stop>
        <div class="notification-header">
          <div class="notification-title">
            <i class="bi bi-bell-fill"></i>
            <span>情绪胶囊提醒</span>
          </div>
          <button class="notification-close" @click="closeNotification">
            <i class="bi bi-x-lg"></i>
          </button>
    </div>

        <div class="notification-content">
          <div class="notification-intro">
            <p>🎉 您的心情胶囊已到开启时间！</p>
            <p>点击下方胶囊查看您曾经的心情记录</p>
        </div>

          <div class="notification-capsules">
            <div v-for="capsule in notificationCapsules" :key="capsule.capsuleId" class="notification-capsule">
              <div class="notification-capsule-header">
                <div class="notification-emotion">
                  <span class="notification-emoji">{{ getEmotionEmoji(capsule.currentEmotion) }}</span>
                  <span class="notification-emotion-text">{{ getEmotionText(capsule.currentEmotion) }}</span>
          </div>
                <div class="notification-time">
                  <i class="bi bi-clock"></i>
                  <span>{{ formatDetailedTime(capsule.openTime) }}</span>
          </div>
              </div>

              <div class="notification-capsule-content">
                <p class="notification-thoughts">{{ capsule.thoughts || '（无内容）' }}</p>
                <div v-if="capsule.futureGoal" class="notification-goal">
                  <strong>目标：</strong>{{ capsule.futureGoal }}
                  </div>
                        </div>

              <div class="notification-actions">
                <button class="notification-btn notification-btn-primary" @click="markNotificationRead(capsule.capsuleId)">
                  <i class="bi bi-check-lg"></i>
                  我知道了
                </button>
                <button class="notification-btn notification-btn-secondary" @click="closeNotification">
                  稍后查看
                </button>
                        </div>
              </div>
          </div>
            </div>
          </div>
              </div>

    <!-- 媒体预览弹窗 -->
    <div v-if="showMediaPreview" class="media-preview-overlay" @click="closeMediaPreview">
      <div class="media-preview-modal" @click.stop>
        <div class="media-preview-header">
          <div class="media-preview-title">
            <i class="bi bi-file-earmark"></i>
            <span>媒体预览</span>
          </div>
          <button class="media-preview-close" @click="closeMediaPreview">
            <i class="bi bi-x-lg"></i>
                  </button>
        </div>

        <div class="media-preview-content">
          <!-- 图片预览 -->
          <div v-if="mediaPreviewType === 'image'" class="media-image-container">
            <img
              :src="getMediaUrl(currentMedia?.mediaUrl)"
              class="media-preview-image"
              alt="图片预览"
              @error="handleImageError"
            />
      </div>

          <!-- 视频预览 -->
          <div v-else-if="mediaPreviewType === 'video'" class="media-video-container">
            <video
              :src="getMediaUrl(currentMedia?.mediaUrl)"
              class="media-preview-video"
              controls
              @error="handleVideoError"
            >
              您的浏览器不支持视频播放
            </video>
    </div>

          <!-- 音频预览 -->
          <div v-else-if="mediaPreviewType === 'audio'" class="media-audio-container">
            <div class="audio-player">
              <div class="audio-icon">
                <i class="bi bi-music-note"></i>
  </div>
              <audio
                :src="getMediaUrl(currentMedia?.mediaUrl)"
                controls
                class="media-preview-audio"
                @error="handleAudioError"
              >
                您的浏览器不支持音频播放
              </audio>
        </div>
      </div>

          <!-- 其他文件 -->
          <div v-else class="media-other-container">
            <div class="other-file">
              <i class="bi bi-file-earmark"></i>
              <span>{{ getMediaShortName(currentMedia?.mediaUrl) }}</span>
              <a :href="getMediaUrl(currentMedia?.mediaUrl)" download class="download-btn">
                <i class="bi bi-download"></i>
                下载
              </a>
    </div>
  </div>
    </div>
    </div>
    </div>
    </div>
</template>

<script setup>
import { ref, onMounted, nextTick, onUnmounted } from 'vue'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

// 响应式数据
const currentEmotion = ref('happy')
const thoughts = ref('')
const goals = ref('')
const openDate = ref('')
const reminderType = ref('app_notification')
const mediaFiles = ref([])
const isSaving = ref(false)
const showCreate = ref(true)
const showList = ref(false)
const capsuleList = ref([])

// 通知相关
const showNotification = ref(false)
const notificationCapsules = ref([])
const notificationTimer = ref(null)

// 媒体预览相关
const showMediaPreview = ref(false)
const currentMedia = ref(null)
const mediaPreviewType = ref('')

// DOM引用
const cloudBg = ref(null)
const floatingCapsule = ref(null)
const starsBg = ref(null)
const createCapsuleContainer = ref(null)
const capsuleListContainer = ref(null)
const photoInput = ref(null)
const mediaInput = ref(null)

// 触发照片选择
function triggerPhotoInput() {
  photoInput.value?.click()
}

// 触发媒体选择（视频/音频）
function triggerMediaInput() {
  mediaInput.value?.click()
}

// 处理照片选择
function handlePhotoChange(event) {
  const files = Array.from(event.target.files)
  addValidFiles(files)
  event.target.value = ''
}

// 处理媒体选择（视频/音频）
function handleMediaChange(event) {
  const files = Array.from(event.target.files)
  addValidFiles(files)
  event.target.value = ''
}

// 添加有效文件
function addValidFiles(files) {
  const validFiles = files.filter(file => {
    const supportedTypes = [
      'image/jpeg', 'image/png', 'image/gif', 'image/webp',
      'audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/ogg', 'audio/aac',
      'video/mp4', 'video/avi', 'video/mov', 'video/wmv'
    ]

    const isValid = supportedTypes.includes(file.type)
    if (!isValid) {
      ElMessage.warning(`不支持的文件类型: ${file.name}`)
    }
    return isValid
  })

  mediaFiles.value.push(...validFiles)
}

// 移除文件
function removeFile(index) {
  mediaFiles.value.splice(index, 1)
}

// 显示创建表单
function showCreateForm() {
  showCreate.value = true
  showList.value = false
}

// 显示胶囊列表
function showCapsuleList() {
  showList.value = true
  showCreate.value = false
  loadCapsuleList()
}

// 保存胶囊
async function saveCapsule() {
  if (!thoughts.value.trim() || !openDate.value) {
    ElMessage.warning('请填写完整信息')
    return
  }

  isSaving.value = true

  try {
    // 添加封存动画效果
    const saveButton = document.querySelector('.btn-capsule')
    if (saveButton) {
      // 按钮缩放动画
      saveButton.style.transform = 'scale(0.9)'
      saveButton.style.background = 'linear-gradient(135deg, #ff6b9d, #6a11cb)'

      // 添加闪光效果
      const sparkle = document.createElement('div')
      sparkle.className = 'save-sparkle'
      sparkle.style.position = 'absolute'
      sparkle.style.top = '50%'
      sparkle.style.left = '50%'
      sparkle.style.transform = 'translate(-50%, -50%)'
      sparkle.style.width = '100px'
      sparkle.style.height = '100px'
      sparkle.style.background = 'radial-gradient(circle, rgba(255,255,255,0.8) 0%, transparent 70%)'
      sparkle.style.borderRadius = '50%'
      sparkle.style.animation = 'saveSparkle 0.6s ease-out'
      sparkle.style.zIndex = '1000'

      saveButton.appendChild(sparkle)

      setTimeout(() => {
        if (sparkle.parentNode) {
          sparkle.parentNode.removeChild(sparkle)
        }
      }, 600)
    }

    // 添加胶囊保存动画
    if (floatingCapsule.value) {
      floatingCapsule.value.style.transform = 'scale(0.8)'
      setTimeout(() => {
        floatingCapsule.value.style.transform = 'scale(1)'
      }, 300)
    }

    const form = new FormData()
    form.append('currentEmotion', currentEmotion.value)
    form.append('thoughts', thoughts.value.trim())
    form.append('futureGoal', goals.value.trim())

    // 修复日期格式：将 yyyy-MM-dd HH:mm 转换为 yyyy-MM-dd'T'HH:mm
    const dateStr = openDate.value
    const formattedDate = dateStr.replace(' ', 'T') // 将空格替换为T
    form.append('openTime', formattedDate)

    form.append('reminderType', reminderType.value)

    // 添加媒体文件
    mediaFiles.value.forEach(file => {
      form.append('mediaFiles', file)
    })

    const response = await request.post('/api/capsules', form)

    if (response.data.code === 200) {
      ElMessage.success('情绪胶囊保存成功！')
      resetForm()
      loadCapsuleList()
    } else {
      ElMessage.error(response.data.message || '保存失败')
    }
  } catch (error) {
    console.error('保存胶囊失败:', error)
    ElMessage.error('保存失败，请稍后重试')
  } finally {
    isSaving.value = false
  }
}

// 重置表单
function resetForm() {
  currentEmotion.value = 'happy'
  thoughts.value = ''
  goals.value = ''
  openDate.value = ''
  reminderType.value = 'app_notification'
  mediaFiles.value = []
}

// 切换详情显示
function toggleDetails(capsule) {
  capsule.showDetails = !capsule.showDetails
}

// 加载胶囊列表
async function loadCapsuleList() {
  try {
    const res = await request.get('/api/capsules')
    if (res.data.code === 200) {
      // 为每个胶囊添加showDetails属性
      capsuleList.value = (res.data.data || []).map(capsule => ({
        ...capsule,
        showDetails: false
      }))
    }
  } catch (e) {
    console.error('加载胶囊列表失败:', e)
  }
}

// 删除胶囊
async function deleteCapsule(capsuleId) {
  try {
    const response = await request.delete(`/api/capsules/${capsuleId}`)
    if (response.data.code === 200) {
      ElMessage.success('删除成功')
      loadCapsuleList()
    } else {
      ElMessage.error(response.data.message || '删除失败')
    }
  } catch (error) {
    console.error('删除胶囊失败:', error)
    ElMessage.error('删除失败，请稍后重试')
  }
}

// 获取情绪对应的emoji
function getEmotionEmoji(emotion) {
  const emojiMap = {
    'happy': '😊',
    'sad': '😢',
    'angry': '😠',
    'anxious': '😰',
    'excited': '🤩',
    'peaceful': '😌',
    'confused': '😕',
    'grateful': '🥰'
  }
  return emojiMap[emotion] || '😊'
}

// 获取情绪文本
function getEmotionText(emotion) {
  const textMap = {
    'happy': '开心',
    'sad': '悲伤',
    'angry': '愤怒',
    'anxious': '焦虑',
    'excited': '兴奋',
    'peaceful': '平静',
    'confused': '困惑',
    'grateful': '感恩'
  }
  return textMap[emotion] || '开心'
}

// 格式化时间
function formatTime(time) {
  if (!time) return ''
  const d = new Date(time)
  const now = new Date()
  const diff = d.getTime() - now.getTime()
  const diffDays = Math.floor(diff / (1000 * 60 * 60 * 24))
  const diffHours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
  const diffMinutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))

  // 如果时间已过
  if (diff < 0) {
    const absDiff = Math.abs(diff)
    const absDays = Math.floor(absDiff / (1000 * 60 * 60 * 24))
    const absHours = Math.floor((absDiff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    const absMinutes = Math.floor((absDiff % (1000 * 60 * 60)) / (1000 * 60))

    if (absDays > 0) {
      return `${absDays}天${absHours}小时前`
    } else if (absHours > 0) {
      return `${absHours}小时${absMinutes}分钟前`
    } else if (absMinutes > 0) {
      return `${absMinutes}分钟前`
    } else {
      return '刚刚'
    }
  }

  // 如果时间未到
  if (diffDays > 0) {
    return `${diffDays}天后`
  } else if (diffHours > 0) {
    return `${diffHours}小时${diffMinutes}分钟后`
  } else if (diffMinutes > 0) {
    return `${diffMinutes}分钟后`
  } else {
    return '即将开启'
  }
}

// 格式化日期
function formatDate(time) {
  if (!time) return ''
  const d = new Date(time)
  return d.toLocaleDateString()
}

// 格式化详细时间
function formatDetailedTime(time) {
  if (!time) return ''
  const d = new Date(time)
  const year = d.getFullYear()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  const hours = String(d.getHours()).padStart(2, '0')
  const minutes = String(d.getMinutes()).padStart(2, '0')

  return `${year}年${month}月${day}日 ${hours}:${minutes}`
}

// 检查通知
async function checkNotifications() {
  try {
    const res = await request.get('/api/capsules/reminders/unread')
    if (res.data.code === 200) {
      notificationCapsules.value = res.data.data || []
      showNotification.value = notificationCapsules.value.length > 0

      // 如果有新通知，显示浏览器通知
      if (notificationCapsules.value.length > 0 && 'Notification' in window) {
        if (Notification.permission === 'granted') {
          new Notification('情绪胶囊提醒', {
            body: `您有 ${notificationCapsules.value.length} 个情绪胶囊已到开启时间`,
            icon: '/src/static/imgs/back.png'
          })
        } else if (Notification.permission !== 'denied') {
          Notification.requestPermission()
        }
      }
    }
  } catch (error) {
    console.error('检查通知失败:', error)
  }
}

// 标记通知为已读
async function markNotificationRead(capsuleId) {
  try {
    await request.post(`/api/capsules/reminders/read/${capsuleId}`)
    notificationCapsules.value = notificationCapsules.value.filter(c => c.capsuleId !== capsuleId)
    if (notificationCapsules.value.length === 0) {
      showNotification.value = false
    }
    ElMessage.success('已标记为已读')
  } catch (error) {
    console.error('标记已读失败:', error)
    ElMessage.error('操作失败')
  }
}

// 关闭通知弹窗
function closeNotification() {
  showNotification.value = false
}

// 获取媒体文件完整URL
function getMediaUrl(mediaUrl) {
  if (!mediaUrl) return ''
  if (mediaUrl.startsWith('http')) return mediaUrl

  // 确保URL以/开头
  const cleanUrl = mediaUrl.startsWith('/') ? mediaUrl : `/${mediaUrl}`
  return `http://localhost:8081${cleanUrl}`
}

// 获取媒体文件类型
function getMediaType(mediaUrl) {
  if (!mediaUrl) return ''
  const lowerPath = mediaUrl.toLowerCase()
  if (lowerPath.match(/\.(jpg|jpeg|png|gif|webp)$/)) return 'image'
  if (lowerPath.match(/\.(mp3|wav|ogg|aac|m4a|nvm|ncm)$/)) return 'audio'
  if (lowerPath.match(/\.(mp4|avi|mov|wmv|flv)$/)) return 'video'
  return 'other'
}

// 获取媒体文件短名称
function getMediaShortName(mediaUrl) {
  if (!mediaUrl) return ''
  const fileName = mediaUrl.split('/').pop()
  if (fileName.length > 15) {
    return fileName.substring(0, 12) + '...'
  }
  return fileName
}



// 关闭媒体预览
function closeMediaPreview() {
  showMediaPreview.value = false
  currentMedia.value = null
  mediaPreviewType.value = ''
}

// 滚动到内容区域
function scrollToContent() {
  nextTick(() => {
    createCapsuleContainer.value?.scrollIntoView({ behavior: 'smooth' })
  })
}

// 处理图片加载错误
function handleImageError(event) {
  console.error('图片加载失败:', event.target.src)
  ElMessage.error('图片加载失败，请检查文件是否存在')
}

// 处理视频加载错误
function handleVideoError(event) {
  console.error('视频加载失败:', event.target.src)
  ElMessage.error('视频文件无法播放，请检查文件格式')
}

// 处理音频加载错误
function handleAudioError(event) {
  console.error('音频加载失败:', event.target.src)
  ElMessage.error('音频文件无法播放，请检查文件格式')
}

// 预览媒体文件
function previewMedia(media) {
  console.log('预览媒体文件:', media)
  currentMedia.value = media
  mediaPreviewType.value = getMediaType(media.mediaUrl)
  const mediaUrl = getMediaUrl(media.mediaUrl)
  console.log('媒体URL:', mediaUrl)
  showMediaPreview.value = true
}



onMounted(() => {
  console.log('Capsule组件已挂载')

  try {
    // 添加滚动背景颜色变化
    window.addEventListener('scroll', () => {
      const scrollY = window.scrollY
      const maxScroll = document.body.scrollHeight - window.innerHeight
      const scrollPercent = scrollY / maxScroll

      const capsulePage = document.querySelector('.capsule-page')
      if (capsulePage) {
        const hue = 200 + scrollPercent * 60 // 从蓝色渐变到紫色
        capsulePage.style.background = `linear-gradient(to bottom, hsl(${hue}, 70%, 85%), hsl(${hue + 20}, 70%, 90%))`
      }
    })
    // 初始化日期选择器
    if (typeof flatpickr !== 'undefined') {
      flatpickr("#openDate", {
        locale: "zh",
        minDate: "today",
        dateFormat: "Y-m-d H:i",
        enableTime: true,
        time_24hr: true,
        defaultDate: new Date(Date.now() + 86400000),
        placeholder: "选择开启日期和时间"
      })
    }

    // 初始化Bootstrap工具提示
    if (typeof bootstrap !== 'undefined') {
      const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
      tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl)
      })
    }

    // 初始化粒子动画
    if (typeof particlesJS !== 'undefined') {
      particlesJS('particles-js', {
        particles: {
          number: {
            value: 80,
            density: {
              enable: true,
              value_area: 800
            }
          },
          color: {
            value: '#ffffff'
          },
          shape: {
            type: 'circle',
            stroke: {
              width: 0,
              color: '#000000'
            },
            polygon: {
              nb_sides: 5
            }
          },
          opacity: {
            value: 0.5,
            random: false,
            anim: {
              enable: false,
              speed: 1,
              opacity_min: 0.1,
              sync: false
            }
          },
          size: {
            value: 3,
            random: true,
            anim: {
              enable: false,
              speed: 40,
              size_min: 0.1,
              sync: false
            }
          },
          line_linked: {
            enable: true,
            distance: 150,
            color: '#ffffff',
            opacity: 0.4,
            width: 1
          },
          move: {
            enable: true,
            speed: 6,
            direction: 'none',
            random: false,
            straight: false,
            out_mode: 'out',
            bounce: false,
            attract: {
              enable: false,
              rotateX: 600,
              rotateY: 1200
            }
          }
        },
        interactivity: {
          detect_on: 'canvas',
          events: {
            onhover: {
              enable: true,
              mode: 'repulse'
            },
            onclick: {
              enable: true,
              mode: 'push'
            },
            resize: true
          },
          modes: {
            grab: {
              distance: 400,
              line_linked: {
                opacity: 1
              }
            },
            bubble: {
              distance: 400,
              size: 40,
              duration: 2,
              opacity: 8,
              speed: 3
            },
            repulse: {
              distance: 200,
              duration: 0.4
            },
            push: {
              particles_nb: 4
            },
            remove: {
              particles_nb: 2
            }
          }
        },
        retina_detect: true
      })
    }

  // 启动通知检查
  checkNotifications()
  notificationTimer.value = setInterval(checkNotifications, 60000) // 每分钟检查一次

  // 创建云朵
  if (cloudBg.value) {
    for (let i = 0; i < 15; i++) {
      const cloud = document.createElement('div')
      cloud.className = 'cloud'
      cloud.style.width = `${Math.random() * 300 + 150}px`
      cloud.style.height = `${Math.random() * 150 + 80}px`
      cloud.style.left = `${Math.random() * 100}%`
      cloud.style.top = `${Math.random() * 60}%`
      cloud.style.animationDelay = `${Math.random() * 20}s`
      cloud.style.animationDuration = `${Math.random() * 30 + 20}s`
      cloudBg.value.appendChild(cloud)
    }
  }

  // 漂浮胶囊动画
  if (floatingCapsule.value) {
    let capsuleY = 0
    let capsuleDirection = 1

    function floatCapsule() {
      capsuleY += 0.1 * capsuleDirection
      if (capsuleY > 10 || capsuleY < -10) capsuleDirection *= -1
      floatingCapsule.value.style.transform = `translateY(${capsuleY}px)`
      requestAnimationFrame(floatCapsule)
    }

    floatCapsule()

    // 添加鼠标悬停星光效果
    floatingCapsule.value.addEventListener('mousemove', (e) => {
      const rect = floatingCapsule.value.getBoundingClientRect()
      const x = e.clientX - rect.left
      const y = e.clientY - rect.top

      // 创建星光效果
      const sparkle = document.createElement('div')
      sparkle.className = 'sparkle'
      sparkle.style.left = x + 'px'
      sparkle.style.top = y + 'px'
      sparkle.style.opacity = '1'

      floatingCapsule.value.appendChild(sparkle)

      setTimeout(() => {
        sparkle.style.opacity = '0'
        setTimeout(() => {
          if (sparkle.parentNode) {
            sparkle.parentNode.removeChild(sparkle)
          }
        }, 300)
      }, 100)
    })
  }

  // 创建星星
  if (starsBg.value) {
    for (let i = 0; i < 30; i++) {
      const star = document.createElement('div')
      star.className = 'star'
      star.style.width = `${Math.random() * 5 + 2}px`
      star.style.height = star.style.width
      star.style.left = `${Math.random() * 100}%`
      star.style.bottom = `${Math.random() * 150}px`
      star.style.animationDelay = `${Math.random() * 3}s`
      starsBg.value.appendChild(star)
    }
  }

  // 加载胶囊列表
  loadCapsuleList()
  } catch (error) {
    console.error('Capsule组件初始化失败:', error)
  }
})

// 清理定时器
onUnmounted(() => {
  if (notificationTimer.value) {
    clearInterval(notificationTimer.value)
  }
})
</script>

<style scoped>
/* CSS变量定义 */
.capsule-page {
  --primary-blue: #6a11cb;
  --primary-pink: #ff6b9d;
  --light-blue: #a5d8ff;
  --light-pink: #ffd6e0;
}

.capsule-page {
  min-height: 100vh;
  font-family: 'Arial Rounded MT Bold', 'Arial', sans-serif;
  overflow-x: hidden;
  position: relative;
  background: linear-gradient(to bottom, var(--light-blue), var(--light-pink));
  transition: background 0.5s ease;
  z-index: 1;
  pointer-events: auto;
}

/* 云朵背景 */
.cloud-bg {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100vh;
  z-index: -2;
  overflow: hidden;
  pointer-events: none;
}

.cloud {
  position: absolute;
  background: white;
  border-radius: 50%;
  opacity: 0.8;
  filter: blur(10px);
  animation: floatCloud 20s infinite linear;
}

@keyframes floatCloud {
  0% {
    transform: translateX(-100px);
  }
  100% {
    transform: translateX(calc(100vw + 100px));
  }
}

.header {
  padding: 50px 0 80px;
  text-align: center;
  position: relative;
  z-index: 1;
  min-height: 30vh;
}

.header h1 {
  font-size: 4rem;
  font-weight: 800;
  color: white;
  text-shadow: 3px 3px 0 var(--primary-pink),
  -1px -1px 0 var(--primary-pink),
  1px -1px 0 var(--primary-pink),
  -1px 1px 0 var(--primary-pink);
  margin-bottom: 1rem;
  letter-spacing: 2px;
}

.header p {
  font-size: 1.5rem;
  color: white;
  text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.2);
}

.header-content {
  position: relative;
  padding-bottom: 60px;
}

.intro-text {
  font-size: 1.2rem;
  color: white;
  margin-top: 1rem;
  text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.3);
  opacity: 0.9;
}

.scroll-down {
  position: absolute;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 10;
  cursor: pointer;
}

.arrow {
  width: 30px;
  height: 30px;
  border-bottom: 3px solid var(--light-blue);
  border-right: 3px solid var(--light-blue);
  transform: rotate(45deg);
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%, 20%, 50%, 80%, 100% {
    transform: rotate(45deg) translateY(0);
  }
  40% {
    transform: rotate(45deg) translateY(-20px);
  }
  60% {
    transform: rotate(45deg) translateY(-10px);
  }
}

.floating-capsule {
  width: 180px;
  height: 320px;
  margin: -30px auto 40px;
  background: rgba(165, 216, 255, 0.3);
  border-radius: 140px;
  box-shadow:
    0 15px 30px rgba(0, 0, 0, 0.15),
    inset 0 5px 10px rgba(255, 255, 255, 0.7),
    inset 0 -5px 10px rgba(0, 0, 0, 0.05);
  position: relative;
  overflow: hidden;
  border: 1px solid rgba(255, 255, 255, 0.5);
  background-image:
    radial-gradient(rgba(0, 0, 0, 0.03) 1px, transparent 1px),
    radial-gradient(rgba(0, 0, 0, 0.02) 1px, transparent 1px);
  background-size: 30px 30px;
  background-position: 0 0, 15px 15px;
  transition: all 0.3s ease;
  cursor: pointer;
}

.floating-capsule:hover {
  transform: scale(1.05);
  box-shadow:
    0 20px 40px rgba(0, 0, 0, 0.2),
    inset 0 5px 10px rgba(255, 255, 255, 0.8),
    inset 0 -5px 10px rgba(0, 0, 0, 0.08);
}

.floating-capsule::before {
  content: '';
  position: absolute;
  top: 15px;
  left: 50%;
  transform: translateX(-50%);
  width: 60%;
  height: 40px;
  background: linear-gradient(to bottom, rgba(255, 255, 255, 0.6), rgba(255, 255, 255, 0.2));
  border-radius: 50%;
  box-shadow: 0 2px 5px rgba(255, 255, 255, 0.8);
}

.floating-capsule::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 80%;
  height: 4px;
  background: linear-gradient(90deg, transparent, rgba(200, 200, 220, 0.5), transparent);
  border-radius: 2px;
}

.floating-capsule .inner-glow {
  position: absolute;
  top: 30%;
  left: 20%;
  width: 30px;
  height: 30px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  filter: blur(15px);
  animation: float 6s infinite ease-in-out;
}

.floating-capsule .inner-glow:nth-child(2) {
  top: 60%;
  left: 70%;
  width: 20px;
  height: 20px;
  animation-delay: 2s;
}

@keyframes float {
  0%, 100% {
    transform: translateY(0) scale(1);
  }
  50% {
    transform: translateY(-15px) scale(1.2);
  }
}

/* 星光效果 */
.sparkle {
  position: absolute;
  width: 4px;
  height: 4px;
  background: white;
  border-radius: 50%;
  pointer-events: none;
  opacity: 0;
  transition: opacity 0.3s;
  box-shadow: 0 0 10px rgba(255, 255, 255, 0.8);
  z-index: 10;
}

.capsule-content {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 60%;
  height: 50%;
  background: linear-gradient(to bottom, rgba(255, 255, 255, 0.4), rgba(255, 255, 255, 0.2));
  border-radius: 10px;
  background-image:
    linear-gradient(rgba(0, 0, 0, 0.05) 1px, transparent 1px),
    linear-gradient(90deg, rgba(0, 0, 0, 0.05) 1px, transparent 1px);
  background-size: 20px 20px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
}

/* 固定按钮 */
.fixed-btn {
  position: fixed;
  top: 50%;
  transform: translateY(-50%);
  z-index: 100;
  width: 50px;
  height: 50px;
  border-radius: 50%;
  font-weight: bold;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
}

.fixed-btn:hover {
  transform: translateY(-50%) scale(1.1);
}

.past-btn {
  left: 20px;
  background-color: var(--primary-pink);
  color: white;
}

.new-btn {
  right: 20px;
  background-color: var(--primary-blue);
  color: white;
}

/* 容器样式 */
.container {
  position: relative;
  z-index: 1;
  padding-bottom: 100px;
}

/* 胶囊容器样式 */
.capsule-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 30px;
  background-color: rgba(255, 255, 255, 0.9);
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(5px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.capsule-container:hover {
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
  transform: translateY(-5px);
}

/* 媒体预览区 */
.media-preview {
  border: 2px dashed rgba(106, 17, 203, 0.3);
  border-radius: 15px;
  padding: 20px;
  margin-bottom: 25px;
  min-height: 180px;
  background-color: rgba(255, 255, 255, 0.7);
  transition: all 0.3s;
  text-align: center;
}

.media-preview:hover {
  border-color: rgba(106, 17, 203, 0.6);
  background-color: rgba(255, 255, 255, 0.9);
}

.media-files {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.media-file {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(255, 255, 255, 0.8);
  padding: 10px 15px;
  border-radius: 8px;
  border: 1px solid rgba(106, 17, 203, 0.2);
}

.remove-file {
  background: #ff4757;
  color: white;
  border: none;
  border-radius: 50%;
  width: 20px;
  height: 20px;
  cursor: pointer;
  font-size: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 修改封存按钮样式 */
.btn-capsule {
  background: linear-gradient(135deg, rgba(255, 220, 230, 0.9), rgba(230, 230, 255, 0.8));
  width: 85px;
  height: 85px;
  border-radius: 50%;
  box-shadow:
    0 5px 15px rgba(0, 0, 0, 0.1),
    inset 0 2px 3px rgba(255, 255, 255, 0.8);
  color: #6a11cb;
  font-weight: 700;
  margin: 0 auto;
  display: block;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.btn-capsule:hover:not(:disabled) {
  background: linear-gradient(135deg, rgba(255, 220, 230, 1), rgba(230, 230, 255, 0.9));
  transform: translateY(-3px) scale(1.08);
  box-shadow: 0 8px 20px rgba(106, 17, 203, 0.15);
}

.btn-capsule:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-capsule .hover-text {
  position: absolute;
  bottom: -30px;
  left: 50%;
  transform: translateX(-50%);
  width: 200px;
  text-align: center;
  font-size: 0.9rem;
  opacity: 0;
  transition: opacity 0.3s;
  color: #6a11cb;
  white-space: nowrap;
  text-shadow: 0 1px 2px rgba(255, 255, 255, 0.5);
}

.btn-capsule:hover .hover-text {
  opacity: 1;
}

/* 封存动画 */
@keyframes saveSparkle {
  0% {
    transform: translate(-50%, -50%) scale(0);
    opacity: 1;
  }
  50% {
    transform: translate(-50%, -50%) scale(1.5);
    opacity: 0.8;
  }
  100% {
    transform: translate(-50%, -50%) scale(2);
    opacity: 0;
  }
}

.save-sparkle {
  pointer-events: none;
}

/* 标题样式 */
h2, h3 {
  color: #3a0ca3;
  font-weight: 700;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  position: relative;
  display: inline-block;
}

h2::after, h3::after {
  content: '';
  position: absolute;
  bottom: -8px;
  left: 50%;
  transform: translateX(-50%);
  width: 60px;
  height: 3px;
  background: linear-gradient(90deg, var(--primary-blue), var(--primary-pink));
  border-radius: 3px;
}

/* 粒子背景 */
#particles-js {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100vh;
  z-index: -3;
  background: transparent;
  pointer-events: none;
}

/* 底部星星区域 */
.stars-bg {
  position: fixed;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 150px;
  z-index: -1;
  overflow: hidden;
}

.star {
  position: absolute;
  background: white;
  border-radius: 50%;
  opacity: 0;
  animation: twinkle 3s infinite ease-in-out;
}

@keyframes twinkle {
  0%, 100% {
    opacity: 0;
    transform: scale(0.5);
  }
  50% {
    opacity: 0.8;
    transform: scale(1);
  }
}

.envelope {
  width: 60%;
  height: 40%;
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%) rotate(var(--rotate, 0deg));
  z-index: 1;
  background: linear-gradient(135deg, #f9f5eb 0%, #f0e6d2 100%);
  border-radius: 3px;
  box-shadow:
    0 4px 8px rgba(0, 0, 0, 0.15),
    0 1px 3px rgba(0, 0, 0, 0.08);
  overflow: hidden;
  animation: floatEnvelope 8s infinite ease-in-out;
}

.envelope::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 35%;
  background: linear-gradient(135deg, #e6d9c3 0%, #d9c9a8 100%);
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
  transform-origin: bottom center;
  transform: rotateX(0deg);
  transition: transform 0.5s ease;
}

.envelope::after {
  content: '';
  position: absolute;
  top: 35%;
  left: 50%;
  transform: translateX(-50%);
  width: 0;
  height: 0;
  border-left: 10px solid transparent;
  border-right: 10px solid transparent;
  border-top: 10px solid rgba(0, 0, 0, 0.1);
  box-shadow: 0 2px 0 rgba(255, 255, 255, 0.3);
}

.envelope .texture {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-image:
    linear-gradient(rgba(0, 0, 0, 0.03) 1px, transparent 1px),
    linear-gradient(90deg, rgba(0, 0, 0, 0.02) 1px, transparent 1px);
  background-size: 20px 20px;
  opacity: 0.5;
  pointer-events: none;
}

.envelope .seal {
  position: absolute;
  top: 30%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 20px;
  height: 20px;
  background: none;
  box-shadow: none;
  z-index: 2;
}

.envelope .seal::before,
.envelope .seal::after {
  content: "";
  position: absolute;
  top: 0;
  width: 10px;
  height: 16px;
  background: var(--light-pink);
  border-radius: 50px 50px 0 0;
}

.envelope .seal::before {
  left: 5px;
  transform: rotate(-45deg);
  transform-origin: 0 100%;
}

.envelope .seal::after {
  left: 0;
  transform: rotate(45deg);
  transform-origin: 100% 100%;
}

@keyframes floatEnvelope {
  0%, 100% {
    transform: translate(-50%, -50%) rotate(-2deg);
  }
  50% {
    transform: translate(-50%, -53%) rotate(2deg);
  }
}

.floating-capsule:hover .envelope::before {
  transform: rotateX(15deg);
}

.floating-capsule:hover .envelope {
  --rotate: 1deg;
}

/* 胶囊卡片样式 */
.capsule-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid rgba(106, 17, 203, 0.1);
}

.capsule-time-preview {
  margin-bottom: 15px;
  padding: 10px 0;
}

.capsule-time-preview .time-info {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 13px;
  color: #666;
  justify-content: center;
}

.capsule-time-preview .time-icon {
  font-size: 16px;
}

.capsule-time-preview .time-text {
  font-weight: 500;
}

.capsule-time-preview {
  margin-bottom: 15px;
  padding: 10px 0;
}

.emotion-badge {
  display: flex;
  align-items: center;
  gap: 8px;
  background: linear-gradient(135deg, rgba(106, 17, 203, 0.15), rgba(255, 107, 157, 0.15));
  border: 1px solid rgba(106, 17, 203, 0.25);
  border-radius: 20px;
  padding: 10px 15px;
  font-size: 14px;
  color: #333;
  font-weight: 600;
  box-shadow: 0 2px 8px rgba(106, 17, 203, 0.1);
  transition: all 0.3s ease;
}

.emotion-badge:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(106, 17, 203, 0.2);
}

.emotion-emoji {
  font-size: 20px;
}

.emotion-text {
  font-size: 14px;
  color: #333;
  font-weight: 500;
}

.capsule-status {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #666;
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #ff9800;
  display: inline-block;
  margin-right: 6px;
  transition: background-color 0.3s ease;
}

.status-dot.opened {
  background: #4CAF50;
}

.capsule-content {
  margin-bottom: 15px;
  padding: 15px 0;
}

.content-text {
  font-size: 15px;
  color: #333;
  line-height: 1.8;
  margin-bottom: 15px;
  word-wrap: break-word;
  overflow-wrap: break-word;
  hyphens: auto;
  text-align: justify;
  padding: 0 5px;
}

.goals-text {
  font-size: 13px;
  color: #666;
  line-height: 1.4;
}

.capsule-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 15px;
  border-top: 1px dashed #eee;
}

.time-info {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 13px;
  color: #666;
  flex: 1;
}

.time-icon {
  font-size: 16px;
}

.time-text {
  font-weight: 500;
}

.capsule-actions {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 13px;
  color: #888;
}

.details-btn {
  background: transparent;
  border: none;
  color: #6a11cb;
  cursor: pointer;
  padding: 5px;
  border-radius: 50%;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.details-btn:hover {
  background: rgba(106, 17, 203, 0.1);
  transform: scale(1.1);
}

.details-btn i {
  font-size: 16px;
}

.delete-btn {
  background: #ff4757;
  color: white;
  border: none;
  border-radius: 8px;
  padding: 6px 12px;
  font-size: 13px;
  cursor: pointer;
  transition: background-color 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 5px;
}

.delete-btn:hover {
  background: #e63946;
}

.delete-icon {
  font-size: 16px;
}

.capsule-card {
  border-radius: 16px;
  margin-bottom: 25px;
  overflow: hidden;
  transition: all 0.3s ease;
  background: rgba(255, 255, 255, 0.9);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(106, 17, 203, 0.15);
  position: relative;
  padding: 25px;
  backdrop-filter: blur(10px);
  min-height: 120px;
}

.capsule-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 15px 35px rgba(106, 17, 203, 0.2);
  border-color: rgba(106, 17, 203, 0.3);
}

.capsule-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 5px;
  height: 100%;
  background: linear-gradient(to bottom, var(--primary-blue), var(--primary-pink));
}

/* 详情区域样式 */
.capsule-details {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px dashed rgba(106, 17, 203, 0.2);
  animation: slideDown 0.3s ease-out;
  background: rgba(255, 255, 255, 0.5);
  border-radius: 10px;
    padding: 20px;
  margin: 20px -10px 0 -10px;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.detail-item {
  display: flex;
    align-items: flex-start;
  margin-bottom: 15px;
  font-size: 14px;
  padding: 8px 0;
}

.detail-label {
  color: #666;
  font-weight: 500;
  min-width: 80px;
  margin-right: 10px;
}

.detail-value {
  color: #333;
  flex: 1;
  line-height: 1.4;
}

.goals-text {
  background: linear-gradient(135deg, rgba(255, 107, 157, 0.1), rgba(106, 17, 203, 0.1));
  padding: 10px 15px;
  border-radius: 8px;
  border-left: 3px solid #ff6b9d;
  margin-top: 5px;
  font-style: italic;
  color: #6a11cb;
}

.media-list {
  display: flex;
    flex-direction: column;
  gap: 12px;
  margin-top: 10px;
}

.media-item {
  display: flex;
    align-items: center;
  gap: 10px;
  padding: 12px 15px;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 8px;
  border: 1px solid rgba(106, 17, 203, 0.15);
  transition: all 0.3s ease;
  cursor: pointer;
}

.media-item:hover {
  background: rgba(255, 255, 255, 0.95);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(106, 17, 203, 0.1);
}

.media-icon {
  color: #6a11cb;
  font-size: 16px;
}

.media-name {
  font-size: 12px;
  color: #666;
  word-break: break-all;
}

.media-preview-hint {
  font-size: 10px;
  color: #999;
  margin-left: auto;
}

/* 媒体预览弹窗样式 */
.media-preview-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.7);
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: fadeIn 0.3s ease-out;
}

.media-preview-modal {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  max-width: 80%;
  max-height: 80%;
  overflow: hidden;
  animation: slideUp 0.4s ease-out;
  border: 2px solid rgba(106, 17, 203, 0.2);
}

.media-preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 25px;
  border-bottom: 1px solid rgba(106, 17, 203, 0.2);
  background: linear-gradient(135deg, rgba(106, 17, 203, 0.1), rgba(255, 107, 157, 0.1));
}

.media-preview-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 18px;
  font-weight: 600;
  color: #6a11cb;
}

.media-preview-title i {
  color: #ff6b9d;
    font-size: 20px;
  }

.media-preview-close {
  background: none;
  border: none;
  color: #999;
  cursor: pointer;
  padding: 5px;
  border-radius: 50%;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.media-preview-close:hover {
  background: rgba(106, 17, 203, 0.1);
  color: #6a11cb;
  transform: scale(1.1);
}

.media-preview-content {
  padding: 25px;
  max-height: 60vh;
  overflow-y: auto;
}

.media-image-container {
  text-align: center;
}

.media-preview-image {
  max-width: 100%;
  max-height: 50vh;
  border-radius: 10px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
}

.media-video-container {
  text-align: center;
}

.media-preview-video {
  max-width: 100%;
  max-height: 50vh;
  border-radius: 10px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
}

.media-audio-container {
  text-align: center;
}

.audio-player {
  display: flex;
    flex-direction: column;
  align-items: center;
  gap: 20px;
  padding: 30px;
  background: linear-gradient(135deg, rgba(106, 17, 203, 0.1), rgba(255, 107, 157, 0.1));
  border-radius: 15px;
}

.audio-icon {
  font-size: 48px;
  color: #6a11cb;
}

.media-preview-audio {
    width: 100%;
  max-width: 400px;
}

.media-other-container {
  text-align: center;
}

.other-file {
  display: flex;
    flex-direction: column;
  align-items: center;
  gap: 15px;
  padding: 30px;
  background: linear-gradient(135deg, rgba(106, 17, 203, 0.1), rgba(255, 107, 157, 0.1));
  border-radius: 15px;
}

.other-file i {
  font-size: 48px;
  color: #6a11cb;
}

.other-file span {
  font-size: 16px;
  color: #333;
  font-weight: 500;
}

.download-btn {
  display: flex;
    align-items: center;
    gap: 8px;
  padding: 10px 20px;
  background: linear-gradient(135deg, #6a11cb, #ff6b9d);
  color: white;
  text-decoration: none;
  border-radius: 25px;
  font-weight: 500;
  transition: all 0.3s ease;
  box-shadow: 0 3px 10px rgba(106, 17, 203, 0.3);
}

.download-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(106, 17, 203, 0.4);
  color: white;
}

/* 通知弹窗样式 */
.notification-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: fadeIn 0.3s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.notification-modal {
  background: linear-gradient(135deg, #ffeef2, #fff0f5);
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(255, 182, 193, 0.4);
  max-width: 500px;
  width: 90%;
  max-height: 80vh;
  overflow-y: auto;
  animation: slideUp 0.4s ease-out;
  border: 2px solid rgba(255, 182, 193, 0.3);
}

@keyframes slideUp {
  from {
    transform: translateY(50px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.notification-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 25px;
  border-bottom: 1px solid rgba(255, 182, 193, 0.3);
  background: linear-gradient(135deg, rgba(255, 182, 193, 0.2), rgba(255, 192, 203, 0.2));
}

.notification-title {
  display: flex;
  align-items: center;
  gap: 10px;
    font-size: 18px;
  font-weight: 600;
  color: #ff69b4;
}

.notification-title i {
  color: #ff1493;
  font-size: 20px;
}

.notification-close {
  background: none;
  border: none;
  color: #999;
  cursor: pointer;
  padding: 5px;
  border-radius: 50%;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.notification-close:hover {
  background: rgba(255, 182, 193, 0.2);
  color: #ff1493;
  transform: scale(1.1);
}

.notification-content {
  padding: 25px;
}

.notification-intro {
  text-align: center;
  margin-bottom: 25px;
  color: #666;
  line-height: 1.6;
}

.notification-intro p {
  margin: 5px 0;
  font-size: 14px;
}

.notification-capsules {
  display: flex;
    flex-direction: column;
  gap: 20px;
}

.notification-capsule {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 15px;
  padding: 20px;
  border: 1px solid rgba(255, 182, 193, 0.3);
  box-shadow: 0 5px 15px rgba(255, 182, 193, 0.2);
  transition: all 0.3s ease;
}

.notification-capsule:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(255, 182, 193, 0.3);
}

.notification-capsule-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.notification-emotion {
  display: flex;
  align-items: center;
    gap: 8px;
  background: linear-gradient(135deg, rgba(255, 182, 193, 0.3), rgba(255, 192, 203, 0.3));
  padding: 8px 12px;
  border-radius: 15px;
  border: 1px solid rgba(255, 182, 193, 0.4);
}

.notification-emoji {
  font-size: 18px;
}

.notification-emotion-text {
  font-size: 14px;
  font-weight: 500;
  color: #ff69b4;
}

.notification-time {
  display: flex;
  align-items: center;
  gap: 5px;
    font-size: 12px;
  color: #999;
}

.notification-time i {
  color: #ff1493;
}

.notification-capsule-content {
  margin-bottom: 15px;
}

.notification-thoughts {
    font-size: 14px;
  color: #333;
  line-height: 1.5;
  margin-bottom: 10px;
  }

.notification-goal {
    font-size: 13px;
  color: #666;
  line-height: 1.4;
  padding: 8px 12px;
  background: rgba(255, 182, 193, 0.1);
  border-radius: 8px;
  border-left: 3px solid #ff69b4;
}

.notification-actions {
  display: flex;
  gap: 10px;
}

.notification-btn {
  flex: 1;
  padding: 10px 15px;
  border: none;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 5px;
}

.notification-btn-primary {
  background: linear-gradient(135deg, #ff69b4, #ff1493);
  color: white;
  box-shadow: 0 3px 10px rgba(255, 182, 193, 0.4);
}

.notification-btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(255, 182, 193, 0.5);
}

.notification-btn-secondary {
  background: rgba(255, 255, 255, 0.9);
  color: #666;
  border: 1px solid rgba(255, 182, 193, 0.4);
}

.notification-btn-secondary:hover {
  background: rgba(255, 182, 193, 0.2);
  color: #ff69b4;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .header h1 {
    font-size: 2.5rem;
  }

  .header p {
    font-size: 1rem;
  }

  .floating-capsule {
    width: 200px;
    height: 350px;
  }

  .fixed-btn {
    padding: 10px 15px;
    font-size: 0.8rem;
  }

  .capsule-container {
    padding: 20px;
  }

  .btn-capsule {
    width: 100px;
    height: 100px;
    font-size: 0.9rem;
  }

  .notification-modal {
    width: 95%;
    margin: 20px;
  }

  .notification-content {
    padding: 20px;
  }

  .notification-actions {
    flex-direction: column;
  }
}
</style> 

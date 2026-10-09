<template>
  <div class="whole-bg">
    <div class="user-header">
      <div style="display: flex; align-items: center;">
      <img class="avatar-img" src="/src/assets/assets/imgs/bghalf-2.jpg" alt="avatar" @click="goUpdateInfo" title="点击修改个人信息" />
        <div class="energy-box">
          <span class="energy-icon">⚡</span>
          <span class="energy-value">{{ userEnergy }}</span>
        </div>
        <DailyQuoteDisplay />
      </div>
      <span class="header-title">情绪日记本</span>
      <el-button class="logout" type="warning" @click="logout">退出</el-button>
    </div>
    <el-container>
      <el-aside width="200px">
        <el-menu
          :default-active="defaultUrl"
          class="el-menu-vertical-demo"
          background-color="rgba(255, 255, 255, 0.1)"
          text-color="#666666"
          active-text-color="#7ec6e6"
          @select="handleMenuSelect"
        >
          <el-menu-item index="diary">
            <i class="el-icon-notebook-1"></i>
            <span>情绪日记本</span>
          </el-menu-item>
          <el-menu-item index="analysis">
            <i class="el-icon-data-analysis"></i>
            <span>情绪分析</span>
          </el-menu-item>
          <el-menu-item index="chat">
            <i class="el-icon-chat-dot-round"></i>
            <span>墨语传心</span>
          </el-menu-item>
          <el-menu-item index="planet">
            <i class="el-icon-star-on"></i>
            <span>匿名星球</span>
          </el-menu-item>
          <el-menu-item index="quote">
            <i class="el-icon-sunrise"></i>
            <span>日签展示</span>
          </el-menu-item>
          <el-menu-item index="capsule">
            <i class="el-icon-coin"></i>
            <span>情绪胶囊</span>
            <span v-if="unreadReminders.length > 0" class="red-dot"></span>
          </el-menu-item>
          <el-menu-item index="mysterybox">
            <i class="el-icon-present"></i>
            <span>情绪盲盒</span>
          </el-menu-item>
        </el-menu>
      </el-aside>
      <el-main>
        <router-view></router-view>
      </el-main>
    </el-container>
    <el-dialog v-model="showCapsuleReminder" title="情绪胶囊提醒" width="400px" :close-on-click-modal="false">
      <div v-for="reminder in unreadReminders" :key="reminder.capsuleId" style="margin-bottom: 12px;">
        <div>您的情绪胶囊已到开启时间：{{ reminder.openTime }}</div>
        <div>内容预览：{{ reminder.content ? reminder.content.slice(0, 30) : '（无内容）' }}</div>
        <el-button size="small" type="primary" @click="markRead(reminder.capsuleId)">我知道了</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import DailyQuoteDisplay from './DailyQuoteDisplay.vue'
import request from '@/utils/request'
const router = useRouter()
const route = useRoute()
const defaultUrl = ref('diary')
const userEnergy = ref(0)
const userId = window.sessionStorage.getItem('uid')

watch(
  () => route.path,
  () => {
    defaultUrl.value = route.path.replace('/user/', '')
  }
)
const logout = () => {
  router.push('/login')
}
const handleMenuSelect = (index) => {
  router.push(`/user/${index}`)
}
const goUpdateInfo = () => {
  router.push('/user/update_info')
}

// --------- 胶囊提醒相关 ---------
const unreadReminders = ref([])
const showCapsuleReminder = ref(false)
let reminderCheckTimer = null

async function loadUnreadReminders() {
  try {
    const res = await request.get('/api/capsules/reminders/unread')
    if (res.data.code === 200) {
      unreadReminders.value = res.data.data || []
      showCapsuleReminder.value = unreadReminders.value.length > 0
      console.log('检查到未读提醒数量:', unreadReminders.value.length)
    }
  } catch (e) {
    console.error('加载提醒失败:', e)
  }
}

async function markRead(capsuleId) {
  try {
  await request.post(`/api/capsules/reminders/read/${capsuleId}`)
  unreadReminders.value = unreadReminders.value.filter(r => r.capsuleId !== capsuleId)
  if (unreadReminders.value.length === 0) showCapsuleReminder.value = false
  } catch (e) {
    console.error('标记已读失败:', e)
  }
}

// 启动定时检查提醒
function startReminderCheck() {
  // 每2分钟检查一次提醒
  reminderCheckTimer = setInterval(() => {
    loadUnreadReminders()
  }, 2 * 60 * 1000)
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

async function loadUserEnergy() {
  if (!userId) return
  try {
    const res = await request.get('/api/mystery-box/energy')
  if (res.data.code === 200 && typeof res.data.data === 'number') {
    userEnergy.value = res.data.data
    }
  } catch (error) {
    console.error('获取用户能量值失败:', error)
    userEnergy.value = 0
  }
}



onMounted(() => {
  loadUnreadReminders()
  loadUserEnergy()
  
  // 监听能量值更新事件
  window.addEventListener('energyUpdated', loadUserEnergy)
  // 监听页面激活/失焦事件
  document.addEventListener('visibilitychange', handlePageVisibilityChange)
  // 启动定时检查
  startReminderCheck()
})

onUnmounted(() => {
  // 清理定时器和事件监听器
  stopReminderCheck()
  window.removeEventListener('energyUpdated', loadUserEnergy)
  document.removeEventListener('visibilitychange', handlePageVisibilityChange)
})
</script>

<style scoped>
.whole-bg {
  min-height: 100vh;
  background: url('/static/imgs/image.png') no-repeat center center !important;
  background-size: cover !important;
}
.user-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 30px;
  height: 70px;
  background: transparent !important;
  box-shadow: 0 2px 12px rgba(126,198,230,0.08);
}
.el-aside {
  background: transparent !important;
  position: relative;
}
.el-menu {
  background: transparent !important;
}
.el-main {
  background: transparent !important;
  min-height: calc(100vh - 70px);
  border-radius: 16px 0 0 0;
  margin: 20px 20px 20px 0;
  box-shadow: 0 0 10px rgba(0,0,0,0.05);
  padding: 30px;
}
.avatar-img {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  margin-right: 18px;
  cursor: pointer;
  object-fit: cover;
  border: 2px solid #7ec6e6;
  position: relative;
}

.energy-box {
  position: absolute;
  top: -5px;
  right: -5px;
  background: linear-gradient(45deg, #ff6b6b, #feca57);
  border-radius: 50%;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  color: white;
  font-weight: bold;
  box-shadow: 0 2px 8px rgba(255, 107, 107, 0.3);
  animation: pulse 2s infinite;
}

.energy-icon {
  font-size: 10px;
  margin-right: 2px;
}

.energy-value {
  font-size: 10px;
  font-weight: bold;
}

@keyframes pulse {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.1);
  }
  100% {
    transform: scale(1);
  }
}
.header-title {
  font-size: 22px;
  font-weight: bold;
  color: #7ec6e6;
  letter-spacing: 2px;
}
.logout {
  margin-left: 20px;
}
.red-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  background: red;
  border-radius: 50%;
  margin-left: 4px;
}
</style> 
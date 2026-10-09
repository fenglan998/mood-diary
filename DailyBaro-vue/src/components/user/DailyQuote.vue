<template>
  <div class="daily-quote-navbar">
    <span class="quote-content-navbar">{{ quote ? quote.content : '今天也值得被温柔对待' }}</span>
    <div class="quote-buttons">
      <el-button size="small" class="refresh-btn-navbar" @click="refreshQuote" :loading="refreshing">
        🔄 换一个
      </el-button>
      <el-popover placement="bottom" width="300" trigger="click">
        <template #reference>
          <el-button size="small" class="quote-btn-navbar" :disabled="isModifiedToday">自定义</el-button>
        </template>
        <div class="custom-quote-form">
          <el-input 
            v-model="customQuote" 
            placeholder="输入你的专属日签" 
            maxlength="30" 
            show-word-limit
            style="margin-bottom: 10px;"
          />
          <div class="form-buttons">
            <el-button size="small" @click="clearCustomQuote">清空</el-button>
            <el-button type="primary" size="small" @click="saveCustomQuote" :loading="saving">确定生成</el-button>
          </div>
        </div>
      </el-popover>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

const quote = ref(null)
const customQuote = ref('')
const isModifiedToday = ref(false)
const refreshing = ref(false)
const saving = ref(false)
let refreshTimer = null

async function loadQuote() {
  try {
    // 首先尝试获取自定义日签
    const customResponse = await request.get('/api/quotes/custom')
    console.log('自定义日签接口返回:', customResponse.data)
    if (customResponse.data.code === 200 && customResponse.data.data) {
      quote.value = customResponse.data.data
      // 检查今天是否已经修改过
      const today = new Date()
      const updateTime = new Date(customResponse.data.data.updateTime)
      if (updateTime.toDateString() === today.toDateString()) {
        isModifiedToday.value = true
      } else {
        // 如果不是今天修改的，重置状态
        isModifiedToday.value = false
      }
      return
    }
    
    // 如果没有自定义日签，获取用户专属的随机日签
    await loadRandomQuote()
  } catch (error) {
    console.error('加载日签失败:', error)
    quote.value = { content: '今天也值得被温柔对待' }
    isModifiedToday.value = false
  }
}

// 加载随机日签
async function loadRandomQuote() {
  try {
    const randomResponse = await request.get('/api/quotes/random/user')
    console.log('用户专属随机日签接口返回:', randomResponse.data)
    if (randomResponse.data.code === 200) {
      quote.value = randomResponse.data.data
      // 重置修改状态，因为这是随机日签
      isModifiedToday.value = false
    } else {
      // 如果都失败了，使用默认日签
      quote.value = { content: '今天也值得被温柔对待' }
      isModifiedToday.value = false
    }
  } catch (error) {
    console.error('加载随机日签失败:', error)
    quote.value = { content: '今天也值得被温柔对待' }
    isModifiedToday.value = false
  }
}

// 手动刷新日签
async function refreshQuote() {
  if (refreshing.value) return
  
  try {
    refreshing.value = true
    console.log('手动刷新日签')
    
    // 调用手动随机日签接口，确保每次都是不同的
    const manualResponse = await request.get('/api/quotes/random/user/manual')
    console.log('手动随机日签接口返回:', manualResponse.data)
    
    if (manualResponse.data.code === 200) {
      quote.value = manualResponse.data.data
      // 重置修改状态，因为这是随机日签
      isModifiedToday.value = false
      ElMessage.success('日签已更新')
    } else {
      ElMessage.error('刷新失败，请稍后重试')
    }
  } catch (error) {
    console.error('手动刷新日签失败:', error)
    ElMessage.error('刷新失败，请稍后重试')
  } finally {
    refreshing.value = false
  }
}

// 检查是否需要刷新日签（每天0点后）
function shouldRefreshQuote() {
  const now = new Date()
  const lastRefresh = localStorage.getItem('lastQuoteRefresh')
  if (!lastRefresh) {
    console.log('首次加载日签，需要刷新')
    return true
  }
  
  const lastRefreshDate = new Date(lastRefresh)
  const shouldRefresh = now.toDateString() !== lastRefreshDate.toDateString()
  console.log('检查日签刷新:', {
    now: now.toDateString(),
    lastRefresh: lastRefreshDate.toDateString(),
    shouldRefresh
  })
  return shouldRefresh
}

// 定时检查日签更新
function startQuoteRefreshTimer() {
  refreshTimer = setInterval(() => {
    if (shouldRefreshQuote()) {
      console.log('检测到日期变化，刷新日签')
      loadQuote()
      localStorage.setItem('lastQuoteRefresh', new Date().toISOString())
    }
  }, 60000) // 每分钟检查一次
}

// 页面加载时立即检查一次
function checkAndRefreshQuote() {
  if (shouldRefreshQuote()) {
    console.log('页面加载时检测到需要刷新日签')
    loadQuote()
    localStorage.setItem('lastQuoteRefresh', new Date().toISOString())
  }
}

async function saveCustomQuote() {
  if (!customQuote.value.trim()) {
    ElMessage.warning('请输入日签内容')
    return
  }
  
  saving.value = true
  try {
    const response = await request.post('/api/quotes/custom', {
      content: customQuote.value.trim()
    })
    
    if (response.data.code === 200) {
      ElMessage.success('自定义日签设置成功')
      quote.value = response.data.data
      customQuote.value = ''
      isModifiedToday.value = true
      localStorage.setItem('lastQuoteRefresh', new Date().toISOString())
      
      // 触发全局日签更新事件，通知其他组件更新
      window.dispatchEvent(new CustomEvent('quoteUpdated', {
        detail: { quote: response.data.data }
      }))
    } else {
      ElMessage.error(response.data.message || '设置失败')
    }
  } catch (error) {
    console.error('保存自定义日签失败:', error)
    ElMessage.error('设置失败，请稍后重试')
  } finally {
    saving.value = false
  }
}

// 清空自定义日签输入
function clearCustomQuote() {
  customQuote.value = ''
}

onMounted(() => {
  // 强制清除旧的日签缓存，确保每天都能看到新的日签
  localStorage.removeItem('lastQuoteRefresh')
  console.log('清除日签缓存，强制刷新')
  
  loadQuote()
  startQuoteRefreshTimer()
  checkAndRefreshQuote() // 页面加载时立即检查一次
  
  // 监听全局日签更新事件
  window.addEventListener('quoteUpdated', (event) => {
    if (event.detail && event.detail.quote) {
      quote.value = event.detail.quote
      isModifiedToday.value = true
    }
  })
})

onUnmounted(() => {
  if (refreshTimer) {
    clearInterval(refreshTimer)
  }
})
</script>

<style scoped>
.daily-quote-navbar {
  background: rgba(255,255,255,0.85) !important;
  display: flex;
  align-items: center;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  padding: 0 14px;
  margin-left: 8px;
  min-width: 320px;
  max-width: 480px;
  height: 44px;
}

.custom-quote-form {
  padding: 10px 0;
}

.form-buttons {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.quote-content-navbar {
  flex: 1;
  font-size: 16px;
  color: #333;
  font-weight: 500;
  white-space: pre-line;
  word-break: break-all;
  overflow: hidden;
  text-overflow: ellipsis;
  margin-right: 16px;
  min-width: 0;
}

.quote-buttons {
  display: flex;
  gap: 8px;
  align-items: center;
}

.refresh-btn-navbar {
  font-size: 11px;
  padding: 4px 6px;
  border-radius: 6px;
  background: rgba(255,255,255,0.85);
  border: 1px solid rgba(0,0,0,0.04);
  color: #ffb6c1;
  transition: all 0.2s;
  min-width: auto;
}

.refresh-btn-navbar:hover:not(:disabled) {
  background: rgba(255,255,255,1);
  border-color: rgba(0,0,0,0.08);
}

.refresh-btn-navbar:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.quote-btn-navbar {
  font-size: 11px;
  padding: 4px 8px;
  border-radius: 6px;
  background: rgba(255,255,255,0.85);
  border: 1px solid rgba(0,0,0,0.04);
  color: #87ceeb;
  transition: all 0.2s;
}

.quote-btn-navbar:hover:not(:disabled) {
  background: rgba(255,255,255,1);
  border-color: rgba(0,0,0,0.08);
}

.quote-btn-navbar:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style> 
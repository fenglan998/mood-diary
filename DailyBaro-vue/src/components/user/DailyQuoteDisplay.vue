<template>
  <div class="daily-quote-navbar">
    <span class="quote-content-navbar">{{ quote ? quote.content : '今天也值得被温柔对待' }}</span>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue'
import request from '@/utils/request'

const quote = ref(null)

async function loadQuote() {
  try {
    // 优先自定义日签
    const customResponse = await request.get('/api/quotes/custom')
    if (customResponse.data.code === 200 && customResponse.data.data) {
      quote.value = customResponse.data.data
      return
    }
    // 否则用专属随机日签
    const randomResponse = await request.get('/api/quotes/random/user')
    if (randomResponse.data.code === 200) {
      quote.value = randomResponse.data.data
    } else {
      quote.value = { content: '今天也值得被温柔对待' }
    }
  } catch {
    quote.value = { content: '今天也值得被温柔对待' }
  }
}
onMounted(() => {
  loadQuote()
  
  // 监听全局日签更新事件
  window.addEventListener('quoteUpdated', (event) => {
    if (event.detail && event.detail.quote) {
      quote.value = event.detail.quote
    }
  })
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
  min-width: 180px;
  max-width: 240px;
  height: 38px;
}
.quote-content-navbar {
  flex: 1;
  font-size: 13px;
  color: #333;
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  margin-right: 8px;
}
</style> 
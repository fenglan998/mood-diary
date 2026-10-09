<template>
  <div class="chat-bg">
    <div class="chat-card">
      <div class="title">
        <h2 class="chat-title">墨语传心</h2>
        <p class="subtitle">与AI对话，获得情绪建议与关怀</p>
      </div>
      <div class="chat-content">
        <div class="chat-history" ref="historyRef">
          <div v-for="(message, index) in messages" :key="index" :class="['message', message.role]">
            <img v-if="message.role==='ai'" class="avatar" :src="aiAvatar" />
            <div class="message-content" v-html="formatMessage(message.content)"></div>
            <img v-if="message.role==='user'" class="avatar user" :src="userAvatar" />
          </div>
        </div>
        <div class="chat-input">
          <el-input
            v-model="inputMessage"
            placeholder="请输入你的问题"
            @keyup.enter="sendMessage"
            class="custom-input"
          ></el-input>
          <el-button
            type="primary"
            :loading="loading"
            @click="sendMessage"
            class="send-button"
          >发送</el-button>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import aiAvatar from '@/static/imgs/ai.png'
import userAvatar from '@/static/imgs/avatar.png'
const inputMessage = ref('')
const loading = ref(false)
const messages = ref([])
const historyRef = ref(null)
// 格式化消息内容，去除Markdown标记并优化排版
const formatMessage = (content) => {
  if (!content) return ''
  
  return content
    // 去除 ** 标记
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    // 去除 --- 分隔线，替换为更美观的分隔
    .replace(/---/g, '<hr style="border: none; border-top: 1px solid #e0e0e0; margin: 15px 0;">')
    // 处理 ### 标题
    .replace(/###\s*(.*?)(?=\n|$)/g, '<h3 style="color: #333; margin: 15px 0 10px 0; font-size: 16px; font-weight: bold;">$1</h3>')
    // 处理 - 列表项
    .replace(/^\s*-\s*(.*?)(?=\n|$)/gm, '<li style="margin: 5px 0; padding-left: 10px;">$1</li>')
    // 将连续的列表项包装在 ul 中
    .replace(/(<li[^>]*>.*?<\/li>)+/gs, '<ul style="margin: 10px 0; padding-left: 20px;">$&</ul>')
    // 处理换行
    .replace(/\n/g, '<br>')
    // 处理多个连续的空行
    .replace(/(<br>\s*){3,}/g, '<br><br>')
}

const sendMessage = async () => {
  if (!inputMessage.value.trim()) {
    ElMessage.warning('请输入问题')
    return
  }
  loading.value = true
  messages.value.push({ role: 'user', content: inputMessage.value })
  await nextTick()
  if (historyRef.value) historyRef.value.scrollTop = historyRef.value.scrollHeight
  try {
    const response = await fetch('http://127.0.0.1:8081/api/ai/query', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ question: inputMessage.value })
    })
    if (!response.ok) throw new Error('请求失败')
    const data = await response.json()
    if (data.code === 200) {
      messages.value.push({ role: 'ai', content: data.data })
    } else {
      ElMessage.error(data.message || 'AI 服务返回错误')
    }
    await nextTick()
    if (historyRef.value) historyRef.value.scrollTop = historyRef.value.scrollHeight
  } catch (error) {
    console.error('AI请求失败:', error)
    if (error.name === 'TypeError' && error.message.includes('timeout')) {
      ElMessage.error('AI响应超时，请稍后重试')
    } else {
    ElMessage.error('请求失败，请重试')
    }
  } finally {
    loading.value = false
    inputMessage.value = ''
  }
}
</script>
<style scoped>
.chat-bg {
  min-height: 100vh;
  background: url('/src/static/imgs/chat-bg.png') no-repeat center center !important;
  background-size: cover !important;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 20px;
}
.chat-card {
  background: rgba(255,255,255,0.3) !important;
  border-radius: 18px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.1);
  padding: 50px 60px 60px 60px;
  width: 85vw;
  height: 85vh;
  max-width: 1100px;
  max-height: 750px;
  display: flex;
  flex-direction: column;
  gap: 25px;
  position: relative;
  border: 2px solid rgba(255,255,255,0.4);
  backdrop-filter: blur(15px);
}
.chat-title {
  font-size: 36px;
  font-weight: bold;
  color: #ff6b9d;
  margin-bottom: 10px;
  letter-spacing: 4px;
  text-align: center;
  text-shadow: 3px 3px 6px rgba(0,0,0,0.15);
  position: relative;
  z-index: 10;
}
.subtitle {
  color: #888;
  margin-top: 0;
  font-size: 18px;
  text-align: center;
  font-weight: 500;
  text-shadow: 1px 1px 2px rgba(0,0,0,0.1);
  position: relative;
  z-index: 10;
}
.title {
  position: relative;
  z-index: 15;
  background: rgba(255,255,255,0.4);
  border-radius: 12px;
  padding: 15px 20px;
  margin-bottom: 10px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  backdrop-filter: blur(10px);
}
.chat-content {
  display: flex;
  flex-direction: column;
  height: calc(100% - 160px);
  background: rgba(255,255,255,0.4);
  border-radius: 15px;
  padding: 25px;
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255,255,255,0.5);
  margin-top: 20px;
  position: relative;
  z-index: 5;
}
.chat-history {
  flex: 1;
  overflow-y: auto;
  margin-bottom: 25px;
  padding: 20px;
  background: rgba(255,255,255,0.6);
  border-radius: 12px;
  border: 1px solid rgba(255,255,255,0.6);
  position: relative;
  box-shadow: inset 0 2px 8px rgba(0,0,0,0.05);
  min-height: 400px;
}

.message {
  display: flex;
  align-items: flex-end;
  margin-bottom: 20px;
  position: relative;
  z-index: 1;
}
.message.user {
  flex-direction: row-reverse;
}
.message .avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  margin: 0 10px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}
.message .avatar.user {
  margin-left: 10px;
  margin-right: 0;
}
.message-content {
  max-width: 65%;
  padding: 12px 18px;
  border-radius: 18px;
  background: rgba(255,255,255,0.95);
  color: #333;
  word-break: break-all;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  position: relative;
  z-index: 1;
}
.message.ai .message-content {
  background: #ffb6c1;
  color: white;
  border-bottom-left-radius: 6px;
  border-bottom-right-radius: 18px;
  border-top-right-radius: 18px;
  border-top-left-radius: 18px;
}
.message.user .message-content {
  background: #f7cac9;
  color: #fff;
  border-bottom-right-radius: 6px;
  border-bottom-left-radius: 18px;
  border-top-right-radius: 18px;
  border-top-left-radius: 18px;
}
.chat-input {
  display: flex;
  gap: 15px;
  padding: 20px;
  background: rgba(255,255,255,0.5);
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
  border: 1px solid rgba(255,255,255,0.6);
}
.custom-input {
  flex: 1;
}
.custom-input :deep(.el-input__inner) {
  height: 48px;
  border-radius: 8px;
  font-size: 15px;
  transition: all 0.3s ease;
  padding: 0 18px;
  background: rgba(255, 255, 255, 0.95);
  border: 2px solid transparent;
}
.custom-input :deep(.el-input__inner):focus {
  border-color: #ffb6c1;
  box-shadow: 0 0 0 3px rgba(255,182,193,0.15);
  background: rgba(255, 255, 255, 1);
}
.custom-input :deep(.el-input__inner):hover {
  border-color: #ffb6c1;
}
.send-button {
  height: 48px;
  font-size: 16px;
  font-weight: 500;
  border-radius: 8px;
  background: linear-gradient(135deg, #ffb6c1, #f7cac9);
  border: none;
  transition: all 0.3s ease;
  letter-spacing: 2px;
  color: #fff;
  padding: 0 24px;
  box-shadow: 0 2px 8px rgba(255,182,193,0.2);
}
.send-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(255,182,193,0.3);
  opacity: 0.95;
}
</style>

<template>
  <div class="planet-bg">
    <div class="planet-card">
      <h2 class="planet-title">匿名星球</h2>
      <div class="post-form">
        <div class="input-container">
          <textarea
            v-model="newPost.content"
            placeholder="说点什么..."
            class="post-input"
            @input="handleInput"
            ref="textareaRef"
          ></textarea>
          <div class="emoji-panel" v-if="showEmojiPanel">
            <div class="emoji-list">
              <span
                v-for="emoji in emojiList"
                :key="emoji"
                class="emoji-item"
                @click="insertEmoji(emoji)"
              >
                {{ emoji }}
              </span>
            </div>
          </div>
        </div>
        <div class="form-controls">
          <button class="emoji-btn" @click="toggleEmojiPanel">😊</button>
          <div class="visibility-select">
            <label>可见范围:</label>
            <select v-model="newPost.visibility">
              <option value="public">公开</option>
              <option value="private">仅自己可见</option>
            </select>
          </div>
        </div>
        <button @click="createPost" class="post-btn">发布动态</button>
      </div>
      <div class="post-list">
        <div v-for="post in posts" :key="post.postId" class="post-item">
          <div class="post-header">
            <span class="post-date">{{ formatTime(post.createTime) }}</span>
          </div>
          <div class="post-content">
            <p>{{ post.content }}</p>
          </div>
          <div class="post-actions">
            <button class="comment-btn" @click.stop="showComments(post)">
              评论
            </button>
            <button
              class="like-btn"
              :class="{ liked: post.liked }"
              @click.stop="likePost(post)"
            >
                                                        <img 
                :src="post.liked ? '/static/imgs/liked.png' : '/static/imgs/like.png'" 
                :alt="post.liked ? '已点赞' : '点赞'"
                class="like-icon"
              />
              {{ post.liked ? '已点赞' : '点赞' }}({{ post.likeCount }})
            </button>
          </div>
          <!-- 评论展开区域 -->
          <div class="comments-section" v-if="post.showComments">
            <div class="comments-bg">
              <div v-if="post.comments && post.comments.length > 0">
                <div v-for="comment in post.comments" :key="comment.commentId" class="comment-item">
                  <span class="comment-author">用户{{ comment.userId }}:</span>
                  <span class="comment-content">{{ comment.content }}</span>
                </div>
              </div>
              <div v-else class="no-comments">
                暂无评论
              </div>
              <!-- 评论输入区域 -->
              <div class="comment-input-section">
                <input 
                  v-model="post.newComment" 
                  placeholder="写评论..." 
                  class="comment-input"
                  @keyup.enter="addComment(post)"
                />
                <button class="comment-submit-btn" @click="addComment(post)">
                  发表
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import request from '@/utils/request'
import dayjs from 'dayjs'
const router = useRouter()
const posts = ref([])
const newPost = ref({ content: '', visibility: 'public' })
const showEmojiPanel = ref(false)
const textareaRef = ref(null)
const emojiList = ['😊', '😂', '😍', '🤔', '😭', '😡', '😱', '😴', '🤗', '😎', '🥰', '😋', '🤩', '😇', '🤠', '👻', '💪', '👍', '👎', '❤️', '💔', '💯', '🔥', '💩', '🌈', '⭐', '🎉', '🎊', '🎈', '🎁', '🍕', '🍔', '🍦', '☕', '🍺', '🍷', '🚗', '✈️', '🏠', '🌙', '☀️', '🌧️', '❄️', '🌸', '🌹', '🌻', '🌴', '🐱', '🐶', '🐼', '🦄', '🐸', '🦋', '🐞', '🦁', '🐯', '🐨', '🐷', '🐸', '🐙', '🦑', '🦐', '🦞', '🦀', '🐡', '🐠', '🐟', '🐬', '🐳', '🐋', '🦈', '🐊', '🐅', '🐆', '🦓', '🦍', '🦧', '🐘', '🦛', '🦏', '🐪', '🐫', '🦒', '🦘', '🐃', '🐂', '🐄', '🐎', '🐖', '🐏', '🐑', '🐐', '🦌', '🐕', '🐩', '🐈', '🐓', '🦃', '🦚', '🦜', '🦢', '🦩', '🕊️', '🐇', '🦝', '🦨', '🦡', '🦫', '🦦', '🦥', '🐁', '🐀', '🐿️', '🦔']
async function loadPosts() {
  const res = await request.get('/api/anonymous-posts')
  posts.value = res.data.data || []
  // 为每个帖子添加showComments属性和newComment属性
  posts.value.forEach(post => {
    post.showComments = false
    post.newComment = ''
  })
}
async function likePost(post) {
  if (post.liked) {
    await request.delete(`/api/anonymous-posts/${post.postId}/like`)
  } else {
    await request.post(`/api/anonymous-posts/${post.postId}/like`)
  }
  loadPosts()
}
async function showComments(post) {
  if (!post.showComments) {
    // 展开评论时，获取评论数据
    try {
      const response = await request.get(`/api/anonymous-posts/${post.postId}/comments`)
      if (response.data.code === 200) {
        post.comments = response.data.data || []
      } else {
        post.comments = []
      }
    } catch (error) {
      console.error('获取评论失败:', error)
      post.comments = []
    }
  }
  post.showComments = !post.showComments
}

async function addComment(post) {
  if (!post.newComment || !post.newComment.trim()) {
    return
  }
  
  try {
    const commentData = {
      content: post.newComment.trim()
    }
    
    const response = await request.post(`/api/anonymous-posts/${post.postId}/comments`, commentData)
    if (response.data.code === 200) {
      // 评论发表成功，重新获取评论列表
      post.newComment = ''
      await showComments(post)
    } else {
      console.error('发表评论失败:', response.data.message)
    }
  } catch (error) {
    console.error('发表评论失败:', error)
  }
}

function goDetail(id) { 
  router.push(`/user/planet/detail/${id}`) 
}
async function createPost() {
  if (!newPost.value.content.trim()) return
  await request.post('/api/anonymous-posts', {
    content: newPost.value.content,
    visibility: newPost.value.visibility
  })
  newPost.value = { content: '', visibility: 'public' }
  loadPosts()
}
function formatTime(time) {
  if (!time) return ''
  // 支持时间戳（number）或字符串
  const t = typeof time === 'number' ? time : Number(time)
  return dayjs(t).format('YYYY.M.D:')
}
function toggleEmojiPanel() {
  showEmojiPanel.value = !showEmojiPanel.value
}

function insertEmoji(emoji) {
  const textarea = textareaRef.value
  if (textarea) {
    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const text = newPost.value.content
    newPost.value.content = text.substring(0, start) + emoji + text.substring(end)
    // 设置光标位置到插入的emoji后面
    nextTick(() => {
      textarea.focus()
      textarea.setSelectionRange(start + emoji.length, start + emoji.length)
    })
  }
  showEmojiPanel.value = false
}

function handleInput() {
  // 可以在这里添加输入处理逻辑
}
onMounted(() => { loadPosts() })
</script>
<style scoped>
.planet-bg {
  min-height: 100vh;
  background: rgba(255,255,255,0.85) !important;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  padding: 40px 0;
}
.planet-card {
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
.planet-title {
  font-size: 28px;
  font-weight: bold;
  color: #7ec6e6;
  margin-bottom: 10px;
  letter-spacing: 2px;
  text-align: center;
}
.post-btn {
  background: linear-gradient(90deg, #7ec6e6, #f7cac9);
  color: #fff;
  border: none;
  border-radius: 10px;
  padding: 10px 28px;
  font-size: 16px;
  font-weight: bold;
  box-shadow: 0 2px 8px rgba(126,198,230,0.15);
  margin-bottom: 10px;
  cursor: pointer;
  transition: background 0.2s;
}
.post-btn:hover {
  background: linear-gradient(90deg, #f7cac9, #7ec6e6);
}
.post-input {
  flex: 1;
  border-radius: 8px;
  border: 1px solid #e0e0e0;
  padding: 12px;
  font-size: 15px;
  resize: vertical;
  min-height: 80px;
  font-family: inherit;
  background: rgba(255,182,193,0.1);
}
.input-container {
  position: relative;
  margin-bottom: 15px;
}
.form-controls {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 15px;
}
.emoji-btn {
  background: #7ec6e6;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 8px 12px;
  font-size: 16px;
  cursor: pointer;
  transition: background 0.2s;
}
.emoji-btn:hover {
  background: #6bb5d5;
}
.emoji-panel {
  position: absolute;
  top: 100%;
  left: 0;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  z-index: 1000;
  max-width: 300px;
  max-height: 200px;
  overflow-y: auto;
}
.emoji-list {
  display: grid;
  grid-template-columns: repeat(8, 1fr);
  gap: 5px;
  padding: 10px;
}
.emoji-item {
  font-size: 20px;
  cursor: pointer;
  padding: 5px;
  border-radius: 4px;
  transition: background 0.2s;
  text-align: center;
}
.emoji-item:hover {
  background: #f0f0f0;
}
.visibility-select {
  display: flex;
  align-items: center;
  gap: 8px;
}
.visibility-select label {
  font-size: 14px;
  color: #666;
}
.visibility-select select {
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  padding: 6px 10px;
  font-size: 14px;
}
.post-select {
  border-radius: 8px;
  border: 1px solid #e0e0e0;
  padding: 6px 10px;
  font-size: 15px;
}
.publish-btn {
  background: #7ec6e6;
  color: #fff;
  border: none;
  border-radius: 8px;
  padding: 8px 18px;
  font-size: 15px;
  font-weight: bold;
  box-shadow: 0 2px 8px rgba(126,198,230,0.10);
  cursor: pointer;
}
.post-list {
  margin-top: 10px;
}
.post-item {
  background: #f7fafc;
  border-radius: 10px;
  padding: 18px 16px;
  margin-bottom: 14px;
  box-shadow: 0 2px 8px rgba(126,198,230,0.06);
  cursor: pointer;
  transition: box-shadow 0.2s;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.post-header {
  margin-bottom: 8px;
}

.post-date {
  font-size: 14px;
  color: #666;
  font-weight: 500;
}

.post-content {
  margin-bottom: 12px;
}

.post-content p {
  margin: 0;
  font-size: 15px;
  line-height: 1.5;
  color: #333;
}

.post-actions {
  display: flex;
  gap: 10px;
  align-items: center;
}
.post-item:hover {
  box-shadow: 0 6px 18px rgba(126,198,230,0.13);
}
.post-meta {
  font-size: 13px;
  color: #999;
  margin-right: 10px;
}
.comment-btn {
  background: #87ceeb;
  color: #fff;
  border: none;
  border-radius: 8px;
  padding: 6px 18px;
  font-size: 14px;
  font-weight: bold;
  cursor: pointer;
  transition: background 0.2s;
}

.comment-btn:hover {
  background: #98d8f0;
}

.like-btn {
  background: #f0ad4e;
  color: #fff;
  border: none;
  border-radius: 8px;
  padding: 6px 18px;
  font-size: 14px;
  font-weight: bold;
  box-shadow: 0 2px 8px rgba(240,173,78,0.10);
  cursor: pointer;
  transition: background 0.2s;
  display: flex;
  align-items: center;
  gap: 6px;
}
.like-btn.liked {
  background: #ff7e67;
  color: #fff;
  border: 1px solid #ff7e67;
}

.like-icon {
  width: 24px;
  height: 24px;
  object-fit: contain;
  vertical-align: middle;
}

.comments-section {
  margin-top: 12px;
  border-top: 1px solid #e0e0e0;
  padding-top: 12px;
}

.comments-bg {
  background: url('/static/imgs/commentbg.png') no-repeat center center !important;
  background-size: cover !important;
  border-radius: 8px;
  padding: 16px;
  min-height: 120px;
}

.comment-item {
  margin-bottom: 8px;
  display: flex;
  gap: 8px;
}

.comment-author {
  font-weight: bold;
  color: #333;
  font-size: 14px;
}

.comment-content {
  color: #666;
  font-size: 14px;
}

.no-comments {
  text-align: center;
  color: #999;
  font-size: 14px;
  padding: 20px 0;
}

.comment-input-section {
  margin-top: 16px;
  display: flex;
  gap: 8px;
  align-items: center;
}

.comment-input {
  flex: 1;
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  padding: 8px 12px;
  font-size: 14px;
  background: rgba(255,255,255,0.9);
}

.comment-input:focus {
  outline: none;
  border-color: #7ec6e6;
  box-shadow: 0 0 0 2px rgba(126,198,230,0.2);
}

.comment-submit-btn {
  background: #7ec6e6;
  color: white;
  border: none;
  border-radius: 6px;
  padding: 8px 16px;
  font-size: 14px;
  font-weight: bold;
  cursor: pointer;
  transition: background 0.2s;
}

.comment-submit-btn:hover {
  background: #6bb5d5;
}
</style>

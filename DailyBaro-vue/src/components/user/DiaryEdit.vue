<template>
  <div class="edit-bg">
    <div class="edit-card">
      <h2 class="edit-title">{{ isEdit ? '编辑日记' : '新增日记' }}</h2>
      
      <div class="form-group">
        <label class="form-label">
          <span class="label-icon">✏️</span>
          标题
        </label>
        <el-input v-model="title" class="edit-input" placeholder="请输入日记标题" />
      </div>
      
      <div class="form-group">
        <label class="form-label">
          <span class="label-icon">📅</span>
          日期
        </label>
        <el-date-picker v-model="selectedDate" type="date" placeholder="选择日期" class="edit-date" />
      </div>
      
      <div class="form-group">
        <label class="form-label">
          <span class="label-icon">😊</span>
          情绪状态
        </label>
        <el-select v-model="selectedEmotion" placeholder="请选择情绪" class="edit-emotion">
          <el-option label="开心" value="happy" />
          <el-option label="难过" value="sad" />
          <el-option label="焦虑" value="anxious" />
          <el-option label="兴奋" value="excited" />
          <el-option label="平静" value="peaceful" />
        </el-select>
      </div>
      
      <div class="form-group">
        <label class="form-label">
          <span class="label-icon">📝</span>
          内容
        </label>
        <el-input type="textarea" v-model="content" class="edit-textarea" placeholder="记录你今天的心情和感受吧..." />
      </div>
      

      <div class="form-group">
        <label class="form-label">
          <span class="label-icon">📎</span>
          媒体文件
          <span class="label-icon">📎</span>
        </label>
        <input type="file" multiple @change="handleFileChange" accept="image/*,video/*,audio/*" class="file-input" />
        <div class="file-hint">支持图片、视频、音频上传，单文件最大50MB，支持mp3、wav、mp4、mov等格式。</div>
      </div>
      <div class="media-preview">
        <div v-for="(file, idx) in allMedia" :key="file.uid || file.name || file.media_id" class="media-item">
          <img v-if="file.type==='image'" :src="getFullUrl(file.url)" class="media-thumb" @click="previewImage(getFullUrl(file.url))" style="cursor:pointer;" />
          <div v-else-if="file.type==='video'" class="media-thumb" style="cursor:pointer;position:relative;">
            <video :src="getFullUrl(file.url)" style="width:100%;height:100%;object-fit:cover;" muted preload="metadata" @click.stop="previewMedia('video', getFullUrl(file.url))" />
            <div class="media-play-btn" @click.stop="previewMedia('video', getFullUrl(file.url))">&#9654;</div>
          </div>
          <div v-else-if="file.type==='audio'" class="media-thumb" style="cursor:pointer;position:relative;display:flex;align-items:center;justify-content:center;background:#f0f0f0;" @click.stop="previewMedia('audio', getFullUrl(file.url))">
            <span style="font-size:28px;">&#127925;</span>
            <div class="media-play-btn" style="left:auto;right:10px;top:10px;transform:none;" @click.stop="previewMedia('audio', getFullUrl(file.url))">&#9654;</div>
          </div>
          <span class="media-name">{{ file.name || file.originName }}</span>
          <el-button size="small" type="danger" @click="removeFile(file, idx)">删除</el-button>
        </div>
        <el-dialog v-model="showImgDialog" width="auto" top="10vh">
          <img :src="previewImgUrl" style="max-width:80vw;max-height:80vh;display:block;margin:auto;" />
        </el-dialog>
        <el-dialog v-model="showMediaDialog" width="auto" top="10vh">
          <div style="text-align:right;margin-bottom:8px;">
            <el-button size="small" @click="showMediaDialog=false">关闭</el-button>
          </div>
          <video v-if="previewMediaType==='video'" :src="previewMediaUrl" style="max-width:80vw;max-height:80vh;display:block;margin:auto;" controls autoplay @error="onMediaError" />
          <audio v-else-if="previewMediaType==='audio'" :src="previewMediaUrl" style="width:80vw;display:block;margin:auto;" controls autoplay @error="onMediaError" />
          <div v-if="mediaError" style="color:red;text-align:center;margin-top:10px;">文件无法播放，请检查格式或重新上传。</div>
        </el-dialog>
        <el-dialog v-model="showTextDialog" width="500px" top="10vh">
          <div style="white-space:pre-wrap;word-break:break-all;max-height:60vh;overflow:auto;">{{ content }}</div>
        </el-dialog>
      </div>

      <div class="btn-group">
        <button class="draft-btn" @click="saveDraft">保存草稿</button>
        <button class="publish-btn" @click="publish">发布</button>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import request from '@/utils/request'
import { ElMessage } from 'element-plus'
import { ref as vueRef } from 'vue'
const showImgDialog = vueRef(false)
const previewImgUrl = vueRef('')
const showTextDialog = vueRef(false)
function previewImage(url) {
  previewImgUrl.value = url
  showImgDialog.value = true
}
function getFullUrl(url) {
  if (!url) return '';
  if (url.startsWith('http')) return url;
  return 'http://localhost:8081' + url;
}
const route = useRoute()
const router = useRouter()
const isEdit = !!route.params.id
const title = ref('')
const content = ref('')
const selectedDate = ref(new Date())
const selectedEmotion = ref('')

const newFiles = ref([]) // 新上传的文件
const existMedia = ref([]) // 已有媒体（编辑时回显）
const showMediaDialog = vueRef(false)
const previewMediaType = vueRef('')
const previewMediaUrl = vueRef('')
const mediaError = vueRef(false)
function onMediaError() {
  mediaError.value = true
}
// 在每次打开媒体弹窗时重置错误状态
function previewMedia(type, url) {
  previewMediaType.value = type
  previewMediaUrl.value = url
  mediaError.value = false
  showMediaDialog.value = true
}
const allMedia = computed(() => {
  // 统一新上传和已存在的媒体
  return [
    ...existMedia.value.map(m => ({
      ...m,
      url: m.mediaUrl,
      type: m.mediaType,
      name: m.mediaUrl ? m.mediaUrl.split('/').pop() : ''
    })),
    ...newFiles.value
  ]
})

function getFileType(file) {
  if (file.type) {
    if (file.type.startsWith('image')) return 'image'
    if (file.type.startsWith('video')) return 'video'
    if (file.type.startsWith('audio')) return 'audio'
  }
  // 已有媒体
  if (file.media_type) return file.media_type
  return 'other'
}

function handleFileChange(e) {
  const files = Array.from(e.target.files)
  files.forEach(f => {
    const type = getFileType(f)
    const url = URL.createObjectURL(f)
    newFiles.value.push({ file: f, url, type, name: f.name })
  })
}
async function deleteMedia(media, diary) {
  try {
    await request.delete(`/api/diary/media/${media.mediaId}`)
    // 从前端移除
    diary.media = diary.media.filter(m => m.mediaId !== media.mediaId)
    ElMessage.success('删除成功')
  } catch (e) {
    ElMessage.error('删除失败')
  }
}


function removeFile(file, idx) {
  // 新上传的文件
  if (file.file) {
    newFiles.value = newFiles.value.filter(f => f !== file)
    ElMessage.success('已删除')
  } else if (file.media_id) {
    // 已有媒体，调用后端删除
    request.delete(`/api/diary/media/${file.media_id}`).then(() => {
      existMedia.value = existMedia.value.filter(f => f !== file)
      ElMessage.success('已删除')
      // 删除成功后刷新页面数据
      if (isEdit) {
        loadDiary()
      }
    }).catch(error => {
      console.error('删除媒体文件失败:', error)
      ElMessage.error('删除失败')
    })
  } else if (file.mediaId) {
    // 兼容不同的字段名
    request.delete(`/api/diary/media/${file.mediaId}`).then(() => {
      existMedia.value = existMedia.value.filter(f => f !== file)
      ElMessage.success('已删除')
      // 删除成功后刷新页面数据
      if (isEdit) {
        loadDiary()
      }
    }).catch(error => {
      console.error('删除媒体文件失败:', error)
      ElMessage.error('删除失败')
    })
  } else {
    console.warn('无法识别的文件类型:', file)
    ElMessage.warning('无法删除此文件')
  }
}

async function loadDiary() {
  if (!isEdit) return
  try {
    const res = await request.get(`/api/diary/${route.params.id}`)
    const d = res.data.data
    
    // 权限检查：如果不是日记作者，跳转到详情页面
    const currentUserId = window.sessionStorage.getItem('uid')
    if (d.user_id && currentUserId !== d.user_id.toString()) {
      ElMessage.error('您没有权限编辑此日记')
      router.push(`/user/diary/detail/${route.params.id}`)
      return
    }
    
    title.value = d.title
    content.value = d.content
    
    existMedia.value = (d.media || []).map(m => ({
      ...m,
      url: m.mediaUrl,
      type: m.mediaType,
      name: m.mediaUrl ? m.mediaUrl.split('/').pop() : '',
      mediaId: m.mediaId || m.media_id, // 确保有mediaId字段
      media_id: m.mediaId || m.media_id // 兼容两种字段名
    }))
  } catch (error) {
    console.error('加载日记失败:', error)
    ElMessage.error('加载日记失败')
    router.push('/user/diary')
  }
}
async function saveDiary(status, silent = false) {
  const form = new FormData()
  form.append('title', title.value)
  form.append('content', content.value)
  if (isEdit) {
    // 编辑时用 newMediaFiles
    newFiles.value.forEach(f => f.file && form.append('newMediaFiles', f.file))
    form.append('status', status)
    await request.put(`/api/diary/${route.params.id}`, form)
  } else {
    // 新增时用 mediaFiles
    newFiles.value.forEach(f => f.file && form.append('mediaFiles', f.file))
    form.append('status', status)
    await request.post('/api/diary', form)
  }
  if (!silent) ElMessage.success(status === 'draft' ? '草稿已保存' : '发布成功')
  if (!silent) router.push('/user/diary')
}
function saveDraft() { saveDiary('draft') }
function publish() { saveDiary('published') }
onMounted(() => {
  loadDiary()
})
</script>
<style scoped>
.edit-bg {
  min-height: 100vh;
  background: linear-gradient(135deg, #ffeef8 0%, #fff5f5 100%) !important;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  padding: 40px 0;
}
.edit-card {
  background: rgba(255,255,255,0.95) !important;
  border-radius: 18px;
  box-shadow: 0 8px 32px rgba(255, 182, 193, 0.15);
  padding: 36px 32px 32px 32px;
  width: 600px;
  max-width: 95vw;
  display: flex;
  flex-direction: column;
  gap: 18px;
  border: 2px dashed rgba(255, 182, 193, 0.3);
}
.edit-title {
  font-size: 28px;
  font-weight: bold;
  color: #ff69b4;
  margin-bottom: 10px;
  letter-spacing: 2px;
  text-align: center;
}

.form-group {
  margin-bottom: 20px;
}

.form-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: 600;
  color: #ff69b4;
  margin-bottom: 8px;
}

.label-icon {
  font-size: 18px;
}
.edit-input, .edit-date, .edit-emotion, .edit-tags {
  width: 100%;
  border-radius: 10px;
  border: 2px dashed rgba(255, 182, 193, 0.3);
  padding: 12px;
  font-size: 16px;
  background: rgba(255, 255, 255, 0.8);
  transition: all 0.3s ease;
}

.edit-input:focus, .edit-date:focus, .edit-emotion:focus, .edit-tags:focus {
  outline: none;
  border-color: #ffb6c1;
  box-shadow: 0 0 0 3px rgba(255, 182, 193, 0.1);
}
.edit-textarea {
  width: 100%;
  border-radius: 10px;
  border: 2px dashed rgba(255, 182, 193, 0.3);
  padding: 12px;
  font-size: 16px;
  min-height: 120px;
  background: rgba(255, 255, 255, 0.8);
  transition: all 0.3s ease;
  resize: vertical;
}

.edit-textarea:focus {
  outline: none;
  border-color: #ffb6c1;
  box-shadow: 0 0 0 3px rgba(255, 182, 193, 0.1);
}

.file-input {
  width: 100%;
  border-radius: 10px;
  border: 2px dashed rgba(255, 182, 193, 0.3);
  padding: 12px;
  background: rgba(255, 255, 255, 0.8);
  transition: all 0.3s ease;
}

.file-hint {
  color: #999;
  font-size: 13px;
  margin-top: 8px;
}
.edit-tags {
  width: 100%;
  margin-bottom: 10px;
}
.tags {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  margin-bottom: 10px;
}
.tag {
  background: #7ec6e6;
  color: #fff;
  padding: 4px 14px;
  border-radius: 14px;
  font-size: 14px;
}
.tag-label {
  background: #e0f0ff;
  color: #007aff;
  padding: 4px 14px;
  border-radius: 14px;
  font-size: 14px;
  cursor: pointer;
  transition: background 0.2s, color 0.2s;
}
.tag-label input {
  margin-right: 4px;
}
.file-input {
  margin-bottom: 10px;
}
.media-preview {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 10px;
}
.media-item {
  background: #f7fafc;
  border-radius: 8px;
  padding: 6px 12px;
  display: flex;
  align-items: center;
  gap: 8px;
  box-shadow: 0 2px 8px rgba(126,198,230,0.06);
}
.media-thumb {
  width: 60px;
  height: 60px;
  object-fit: cover;
  border-radius: 6px;
  box-shadow: 0 1px 4px rgba(126,198,230,0.10);
}
.media-name {
  font-size: 13px;
  color: #666;
  margin-left: 4px;
}
.remove-btn {
  background: #ff4d4f;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 2px 10px;
  font-size: 13px;
  cursor: pointer;
}
.btn-group {
  display: flex;
  gap: 18px;
  justify-content: center;
  margin-top: 10px;
}
.draft-btn {
  background: linear-gradient(135deg, #ffa500, #ff8c00);
  color: #fff;
  border: none;
  border-radius: 10px;
  padding: 12px 28px;
  font-size: 16px;
  font-weight: bold;
  box-shadow: 0 4px 12px rgba(255, 165, 0, 0.3);
  cursor: pointer;
  transition: all 0.3s ease;
}

.draft-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(255, 165, 0, 0.4);
}

.publish-btn {
  background: linear-gradient(135deg, #32cd32, #228b22);
  color: #fff;
  border: none;
  border-radius: 10px;
  padding: 12px 28px;
  font-size: 16px;
  font-weight: bold;
  box-shadow: 0 4px 12px rgba(50, 205, 50, 0.3);
  cursor: pointer;
  transition: all 0.3s ease;
}

.publish-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(50, 205, 50, 0.4);
}
.diary-edit-bg {
  background: rgba(255,255,255,0.85) !important;
}
.diary-edit-card {
  background: rgba(255,255,255,0.95) !important;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}
</style> 
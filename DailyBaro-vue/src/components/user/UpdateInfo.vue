<template>
  <div class="info-bg">
    <div class="info-card">
      <h2 class="info-title">个人信息</h2>
      <div class="info-content">
        <div class="info-item">
          <span class="info-label">账号：</span>
          <span class="info-value">{{ userInfo.account }}</span>
        </div>
        <div class="info-item">
          <span class="info-label">手机号码：</span>
          <span class="info-value">{{ userInfo.phone || '暂未设置' }}</span>
        </div>
        <div class="info-item">
          <span class="info-label">邮箱地址：</span>
          <span class="info-value">{{ userInfo.email || '暂未设置' }}</span>
        </div>
      </div>
      <div class="btn-group">
        <button class="edit-btn" @click="update">修改信息</button>
        <button class="pwd-btn" @click="showUpdatePwd">修改密码</button>
      </div>
    </div>
    <el-dialog
      title="修改个人信息"
      v-model="updateDialogVisible"
      width="400px"
      :close-on-click-modal="false"
      center>
      <el-form :model="updateUser" label-width="80px" :rules="rules" ref="updateForm">
        <el-form-item label="账号">
          <el-input v-model="updateUser.account" disabled>
            <template #prefix><i class="el-icon-user"></i></template>
          </el-input>
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="updateUser.phone" placeholder="请输入手机号码">
            <template #prefix><i class="el-icon-mobile-phone"></i></template>
          </el-input>
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="updateUser.email" placeholder="请输入邮箱地址">
            <template #prefix><i class="el-icon-message"></i></template>
          </el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="cancelUpdate">取 消</el-button>
        <el-button type="primary" @click="doUpdate" :loading="updating">确 定</el-button>
      </template>
    </el-dialog>
    <el-dialog
      title="修改密码"
      v-model="pwdDialogVisible"
      width="400px"
      :close-on-click-modal="false"
      center>
      <el-form :model="pwdForm" label-width="100px" :rules="pwdRules" ref="pwdFormRef">
        <el-form-item label="原密码" prop="oldPassword">
          <el-input
            v-model="pwdForm.oldPassword"
            type="password"
            show-password
            placeholder="请输入原密码">
            <template #prefix><i class="el-icon-lock"></i></template>
          </el-input>
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input
            v-model="pwdForm.newPassword"
            type="password"
            show-password
            placeholder="请输入新密码">
            <template #prefix><i class="el-icon-key"></i></template>
          </el-input>
        </el-form-item>
        <el-form-item label="确认新密码" prop="confirmPassword">
          <el-input
            v-model="pwdForm.confirmPassword"
            type="password"
            show-password
            placeholder="请再次输入新密码">
            <template #prefix><i class="el-icon-key"></i></template>
          </el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="cancelUpdatePwd">取 消</el-button>
        <el-button type="warning" @click="doUpdatePwd" :loading="updatingPwd">确 定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

const router = useRouter()

// 表单引用
const updateForm = ref(null)
const pwdFormRef = ref(null)

// 用户信息
const userInfo = reactive({
  uid: window.sessionStorage.getItem('uid'),
  account: window.sessionStorage.getItem('account'),
  phone: '',
  email: ''
})
const updateUser = reactive({
  uid: '',
  account: '',
  phone: '',
  email: ''
})
const pwdForm = reactive({
  uid: window.sessionStorage.getItem('uid'),
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

// 控制弹窗
const updateDialogVisible = ref(false)
const pwdDialogVisible = ref(false)
const updating = ref(false)
const updatingPwd = ref(false)

// 校验规则
const validatePhone = (rule, value, callback) => {
  if (value && !/^1[3-9]\d{9}$/.test(value)) {
    callback(new Error('请输入正确的手机号码'))
  } else {
    callback()
  }
}
const validateEmail = (rule, value, callback) => {
  if (value && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
    callback(new Error('请输入正确的邮箱地址'))
  } else {
    callback()
  }
}
const validateNewPassword = (rule, value, callback) => {
  if (value === pwdForm.oldPassword) {
    callback(new Error('新密码不能与原密码相同'))
  } else {
    if (pwdForm.confirmPassword !== '') {
      pwdFormRef.value?.validateField('confirmPassword')
    }
    callback()
  }
}
const validateConfirmPassword = (rule, value, callback) => {
  if (value !== pwdForm.newPassword) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const rules = {
  phone: [
    { validator: validatePhone, trigger: 'blur' }
  ],
  email: [
    { validator: validateEmail, trigger: 'blur' }
  ]
}
const pwdRules = {
  oldPassword: [
    { required: true, message: '请输入原密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能小于6位', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能小于6位', trigger: 'blur' },
    { validator: validateNewPassword, trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

// 获取用户信息
const fetchUserInfo = async () => {
  if (!userInfo.uid) {
    ElMessage.error('用户未登录')
    return
  }
  try {
    const res = await request.get(`/users/getMyInfo/${userInfo.uid}`)
    if (res.data.code === 200) {
      Object.assign(userInfo, res.data.data)
    } else {
      ElMessage.error(res.data.message || '获取用户信息失败')
    }
  } catch (err) {
    ElMessage.error('获取用户信息失败')
  }
}

// 打开修改信息弹窗
const update = () => {
  updateUser.uid = userInfo.uid
  updateUser.account = userInfo.account
  updateUser.phone = userInfo.phone
  updateUser.email = userInfo.email
  updateDialogVisible.value = true
}

// 取消修改信息
const cancelUpdate = () => {
  updateDialogVisible.value = false
  updateForm.value?.resetFields()
}

// 提交修改信息
const doUpdate = () => {
  updateForm.value?.validate(async (valid) => {
    if (valid) {
      updating.value = true
      try {
        const res = await request.post('/users/updateUserInfo', {
          uid: updateUser.uid,
          phone: updateUser.phone,
          email: updateUser.email
        })
        if (res.data.code === 200) {
          ElMessage.success('修改成功')
          updateDialogVisible.value = false
          fetchUserInfo()
        } else {
          ElMessage.error(res.data.message || '更新失败')
        }
      } catch (err) {
        ElMessage.error('更新失败')
      } finally {
        updating.value = false
      }
    }
  })
}

// 打开修改密码弹窗
const showUpdatePwd = () => {
  pwdDialogVisible.value = true
}

// 取消修改密码
const cancelUpdatePwd = () => {
  pwdDialogVisible.value = false
  pwdFormRef.value?.resetFields()
}

// 提交修改密码
const doUpdatePwd = () => {
  pwdFormRef.value?.validate(async (valid) => {
    if (valid) {
      updatingPwd.value = true
      try {
        const res = await request.post('/users/changePassword/' + pwdForm.uid, {
          uid: pwdForm.uid,
          oldPassword: pwdForm.oldPassword,
          newPassword: pwdForm.newPassword
        })
        if (res.data.code === 200) {
          ElMessage.success('密码修改成功，请重新登录')
          pwdDialogVisible.value = false
          setTimeout(() => {
            router.push('/login')
          }, 1500)
        } else {
          ElMessage.error(res.data.message || '更新密码失败')
        }
      } catch (err) {
        ElMessage.error('更新密码失败')
      } finally {
        updatingPwd.value = false
      }
    }
  })
}

onMounted(() => {
  fetchUserInfo()
})
</script>

<style scoped>
.info-bg {
  min-height: 100vh;
  background: linear-gradient(135deg, #7ec6e6 0%, #f7cac9 100%);
  display: flex;
  justify-content: center;
  align-items: flex-start;
  padding: 40px 0;
}
.info-card {
  background: #fff;
  border-radius: 18px;
  box-shadow: 0 8px 32px rgba(126,198,230,0.10);
  padding: 36px 32px 32px 32px;
  width: 500px;
  max-width: 95vw;
  display: flex;
  flex-direction: column;
  gap: 18px;
  align-items: center;
}
.info-title {
  font-size: 28px;
  font-weight: bold;
  color: #7ec6e6;
  margin-bottom: 10px;
  letter-spacing: 2px;
  text-align: center;
}
.info-content {
  width: 100%;
  margin-bottom: 18px;
}
.info-item {
  display: flex;
  gap: 10px;
  margin-bottom: 10px;
  font-size: 16px;
}
.info-label {
  color: #007aff;
  font-weight: bold;
  min-width: 90px;
}
.info-value {
  color: #333;
}
.btn-group {
  display: flex;
  gap: 18px;
  justify-content: center;
  margin-top: 10px;
}
.edit-btn, .pwd-btn {
  background: linear-gradient(90deg, #7ec6e6, #f7cac9);
  color: #fff;
  border: none;
  border-radius: 10px;
  padding: 10px 28px;
  font-size: 16px;
  font-weight: bold;
  box-shadow: 0 2px 8px rgba(126,198,230,0.15);
  cursor: pointer;
  transition: background 0.2s;
}
.edit-btn:hover, .pwd-btn:hover {
  background: linear-gradient(90deg, #f7cac9, #7ec6e6);
}
.update-info-bg {
  background: rgba(255,255,255,0.85) !important;
}
.update-info-card {
  background: rgba(255,255,255,0.95) !important;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}
</style>

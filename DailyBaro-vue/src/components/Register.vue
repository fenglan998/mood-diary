<template>
  <div class="register-container">
    <div class="register-box">
      <el-card class="register-card">
        <div class="logo-box">
          <img src="/src/assets/assets/imgs/bghalf-2.jpg" class="logo-img" alt="logo" />
        </div>
        <div class="title">
          <h2>情绪日记本注册</h2>
          <p class="subtitle">开启你的情绪记录之旅</p>
        </div>
        <el-form 
          :model="registerForm" 
          :rules="registerRules" 
          ref="registerFormRef" 
          class="register-form"
        >
          <div class="form-item">
            <div class="label-box">
              <span class="required">*</span>
              <span class="label">账号</span>
            </div>
            <el-input
              v-model="registerForm.account"
              placeholder="请输入账号"
              class="custom-input">
            </el-input>
          </div>
          <div class="form-item">
            <div class="label-box">
              <span class="required">*</span>
              <span class="label">密码</span>
            </div>
            <el-input
              v-model="registerForm.password"
              type="password"
              placeholder="请输入密码"
              class="custom-input">
            </el-input>
          </div>
          <div class="form-item">
            <div class="label-box">
              <span class="required">*</span>
              <span class="label">确认密码</span>
            </div>
            <el-input
              v-model="registerForm.confirmPassword"
              type="password"
              placeholder="请再次输入密码"
              class="custom-input">
            </el-input>
          </div>
          <div class="btn-container">
            <el-button
              type="primary"
              :loading="loading"
              @click="handleRegister"
              class="register-button">
              注册
            </el-button>
          </div>
          <div class="login-link">
            <el-button type="text" @click="router.push('/login')">
              已有账号？立即登录
            </el-button>
          </div>
        </el-form>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { register } from '@/api/user'

// 路由实例
const router = useRouter()

// 表单引用
const registerFormRef = ref(null)

// 加载状态
const loading = ref(false)

// 注册表单数据
const registerForm = reactive({
  account: '',
  password: '',
  confirmPassword: ''
})

// 密码验证函数
const validatePass2 = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('请再次输入密码'))
  } else if (value !== registerForm.password) {
    callback(new Error('两次输入密码不一致!'))
  } else {
    callback()
  }
}

// 表单验证规则
const registerRules = reactive({
  account: [
    { required: true, message: '请输入账号', trigger: 'blur' },
    { min: 3, message: '账号长度不能小于3位', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能小于6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, validator: validatePass2, trigger: 'blur' }
  ]
})

/**
 * 处理注册逻辑
 */
const handleRegister = async () => {
  if (!registerFormRef.value) return
  
  await registerFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        loading.value = true
        // 只传 account 和 password 给后端
        const payload = {
          account: registerForm.account,
          password: registerForm.password
        }
        const result = await register(payload)
        const { code, message } = result.data
        
        if (code === 1000 || code === 200) {
          ElMessage.success('注册成功')
          router.push('/login')
        } else {
          ElMessage.error(message || '注册失败')
        }
      } catch (error) {
        console.error('注册错误:', error)
        ElMessage.error('注册失败，请重试')
      } finally {
        loading.value = false
      }
    }
  })
}
</script>

<style scoped>
.register-container {
  height: 100vh;
  display: flex;
  justify-content: flex-end;
  align-items: center;
  background: url('/static/imgs/img.png') no-repeat center center;
  background-size: cover;
  padding-right: 80px;
}

.register-box {
  width: 100%;
  max-width: 480px;
  padding: 20px;
}

.register-card {
  background: rgba(255, 255, 255, 0.6);
  border-radius: 20px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  backdrop-filter: blur(15px);
  padding: 40px 50px;
  position: relative;
  border: 1px solid rgba(255, 255, 255, 0.3);
}
.logo-box {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-bottom: 18px;
}
.logo-img {
  width: 60px;
  height: 60px;
  border-radius: 16px;
  object-fit: cover;
  box-shadow: 0 2px 8px rgba(126,198,230,0.15);
}
.title {
  text-align: center;
  margin-bottom: 45px;
}

.title h2 {
  color: #ffb6c1;
  margin: 0;
  font-size: 28px;
  font-weight: 600;
}

.subtitle {
  color: #909399;
  margin-top: 12px;
  font-size: 14px;
}

.register-form {
  margin: 0 auto;
  width: 100%;
}

.form-item {
  margin-bottom: 30px;
  position: relative;
}

.label-box {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
  padding-left: 5px;
}

.required {
  color: #F56C6C;
  margin-right: 4px;
  font-size: 14px;
}

.label {
  font-size: 14px;
  color: #606266;
  font-weight: 500;
}

.custom-input {
  width: 100%;
}

.custom-input :deep(.el-input__inner) {
  height: 42px;
  border-radius: 8px;
  font-size: 14px;
  border: 1px solid rgba(255, 255, 255, 0.4);
  transition: all 0.3s ease;
  padding: 0 15px;
  background: rgba(255, 255, 255, 0.7);
}

.custom-input :deep(.el-input__inner):focus {
  border-color: rgba(255, 182, 193, 0.8);
  box-shadow: 0 0 0 2px rgba(255, 182, 193, 0.2);
  background: rgba(255, 255, 255, 0.9);
}

.custom-input :deep(.el-input__inner):hover {
  border-color: #c0c4cc;
}

.btn-container {
  margin-top: 40px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.register-button {
  width: 100%;
  height: 44px;
  font-size: 16px;
  font-weight: 500;
  border-radius: 8px;
  background: linear-gradient(90deg, rgba(255, 182, 193, 0.9), rgba(255, 192, 203, 0.9));
  border: 1px solid rgba(255, 255, 255, 0.3);
  transition: all 0.3s ease;
  letter-spacing: 2px;
}

.register-button:hover {
  transform: translateY(-1px);
  box-shadow: 0 5px 15px rgba(255, 182, 193, 0.3);
  background: linear-gradient(45deg, rgba(255, 182, 193, 0.9), rgba(255, 192, 203, 0.9));
}

.login-link {
  text-align: center;
  margin-top: 20px;
}

.login-link .el-button {
  color: #ffb6c1;
  background: none;
  border: none;
  padding: 0;
  font: inherit;
  cursor: pointer;
  outline: inherit;
}

.login-link .el-button:hover {
  text-decoration: underline;
}

@media screen and (max-width: 480px) {
  .register-box {
    padding: 15px;
  }

  .register-card {
    padding: 30px 25px;
  }

  .title h2 {
    font-size: 24px;
  }
}
</style>

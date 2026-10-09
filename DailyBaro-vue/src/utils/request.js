import axios from 'axios'
import { ElMessage } from 'element-plus'
import router from '@/router'

// 创建axios实例
const request = axios.create({
  baseURL: 'http://localhost:8081',
  timeout: 30000  // 增加到30秒，给AI分析更多时间
})

// 请求拦截器
request.interceptors.request.use(
  config => {
    // 从sessionStorage获取用户ID并添加到请求头
    const uid = window.sessionStorage.getItem('uid')
    if (uid) {
      config.headers.uid = uid
      console.log('Added uid to request headers:', uid)
    } else {
      console.warn('No uid found in sessionStorage')
    }
    console.log('Request config:', config)
    return config
  },
  error => {
    console.error('请求错误:', error)
    return Promise.reject(error)
  }
)

// 响应拦截器
request.interceptors.response.use(
  response => {
    const res = response.data
    
    // 这里可以根据后端的返回码进行统一处理
    if (res.code !== 200 && res.code !== 1000) {
      ElMessage.error(res.message || '请求失败')
      
      // 处理特定错误码
      if (res.code === 401) {
        // 未登录或token过期
        router.push('/login')
      }
      return Promise.reject(new Error(res.message || '请求失败'))
    }
    return response
  },
  error => {
    console.error('响应错误:', error)
    ElMessage.error(error.message || '网络请求失败')
    return Promise.reject(error)
  }
)

export default request 
import axios from 'axios';
//403.vue - 没有权限时的提示页面
// 404.vue - 页面找不到的提示页面
// http.js - 网络请求配置（连接后端的设置
// 基础url
const request = axios.create({
  baseURL: 'http://localhost:8081',   // 后端的接口地址  ip:port
})

// 调用流式聊天的函数
export const streamChat = (input) => {
  return request({
    method: 'get',
    url: '/ai/streamChat',
    params: { input }
  })
}

export default request
// 作用：整个前端的启动文件，最先执行
// 功能：创建 Vue 应用，加载路由、Element Plus 组件库

import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'

createApp(App).use(router).use(ElementPlus).mount('#app')

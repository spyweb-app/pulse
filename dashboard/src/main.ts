import { createApp } from 'vue'
import { createPinia } from 'pinia'
import 'virtual:uno.css'
import './style.css'
import App from './App.vue'
import router from './router'

createApp(App).use(router).use(createPinia()).mount('#app')

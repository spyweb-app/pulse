import { ref, watch } from 'vue'

export const connected = ref(true)

export interface Toast {
  message: string
  type: 'success' | 'error' | 'warning' | 'info'
}

export const notification = ref<Toast | null>(null)

export function showNotification(msg: string, type: Toast['type'] = 'info') {
  notification.value = { message: msg, type }
  setTimeout(() => { notification.value = null }, 4000)
}

export function clearNotification() {
  notification.value = null
}

const storedRefresh = localStorage.getItem('pulse-auto-refresh')
export const autoRefresh = ref(storedRefresh !== null ? storedRefresh === 'true' : true)
watch(autoRefresh, (v) => {
  localStorage.setItem('pulse-auto-refresh', String(v))
})

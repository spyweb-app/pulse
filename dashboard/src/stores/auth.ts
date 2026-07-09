import { ref } from 'vue'

function getStoredKey(): string {
  try { return localStorage.getItem('pulse_api_key') || '' } catch { return '' }
}

export const apiKey = ref(getStoredKey())
export const showAuthModal = ref(false)
export const keyVersion = ref(0)

export function setApiKey(key: string) {
  apiKey.value = key
  try { localStorage.setItem('pulse_api_key', key) } catch {}
  showAuthModal.value = false
  keyVersion.value++
}

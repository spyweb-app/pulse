import { defineStore } from 'pinia'
import { ref } from 'vue'
import { api, type NotificationChannel } from '~lib/api'

export const useChannelStore = defineStore('channels', () => {
  const channels = ref<NotificationChannel[]>([])
  const loading = ref(false)

  async function load() {
    loading.value = true
    try {
      channels.value = await api.listChannels()
    } finally {
      loading.value = false
    }
  }

  async function toggleEnabled(id: number, enabled: number) {
    await api.updateChannel(id, { enabled })
    const c = channels.value.find(c => c.id === id)
    if (c) c.enabled = enabled
  }

  async function remove(id: number) {
    await api.deleteChannel(id)
    channels.value = channels.value.filter(c => c.id !== id)
  }

  async function create(data: Partial<NotificationChannel>) {
    const ch = await api.createChannel(data)
    channels.value.push(ch)
    return ch
  }

  async function update(id: number, data: Partial<NotificationChannel>) {
    const updated = await api.updateChannel(id, data)
    patch(updated)
  }

  function patch(updated: Partial<NotificationChannel>) {
    const idx = channels.value.findIndex(c => c.id === updated.id)
    if (idx !== -1) {
      channels.value[idx] = { ...channels.value[idx], ...updated }
    }
  }

  return { channels, loading, load, toggleEnabled, remove, create, update }
})

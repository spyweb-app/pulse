import { onMounted, onUnmounted, type Ref } from 'vue'

export function usePoll(cb: () => Promise<void>, intervalMs: number, enabled?: Ref<boolean>) {
  let timer: ReturnType<typeof setInterval> | null = null
  let running = false

  async function tick() {
    if (running || document.hidden) return
    if (enabled && !enabled.value) return
    running = true
    try {
      await cb()
    } catch (e) {
      console.error('Poll error:', e)
    } finally {
      running = false
    }
  }

  onMounted(() => {
    timer = setInterval(tick, intervalMs)
  })

  onUnmounted(() => {
    if (timer) clearInterval(timer)
  })
}

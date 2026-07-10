<template>
  <span class="badge" :class="status.badge">
    <span :class="status.dot"></span>
    {{ status.label }}
  </span>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  isUp?: number
  statusCode?: number | null
}>()

const status = computed(() => {
  if (props.statusCode && props.statusCode >= 400 && props.statusCode < 500)
    return { badge: 'badge-blocked', dot: 'dot-blocked', label: 'Blocked' }
  if (props.isUp === 1)
    return { badge: 'badge-up', dot: 'dot-up', label: 'Up' }
  if (props.isUp === 0)
    return { badge: 'badge-down', dot: 'dot-down', label: 'Down' }
  return { badge: 'badge-paused', dot: 'dot-paused', label: 'N/A' }
})

</script>

<style scoped>
.badge-up {
  @apply inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full;
  color: var(--up);
  background-color: color-mix(in srgb, var(--up) 10%, transparent);
}
.badge-down {
  @apply inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full;
  color: var(--down);
  background-color: color-mix(in srgb, var(--down) 10%, transparent);
}
.badge-paused {
  @apply inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full;
  color: var(--paused);
  background-color: color-mix(in srgb, var(--paused) 10%, transparent);
}
.badge-blocked {
  @apply inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full;
  color: var(--blocked);
  background-color: color-mix(in srgb, var(--blocked) 10%, transparent);
}

.dot-up, .dot-down, .dot-paused, .dot-blocked {
  @apply w-2 h-2 rounded-full inline-block;
}
.dot-up { background: var(--up); }
.dot-down { background: var(--down); }
.dot-paused { background: var(--paused); }
.dot-blocked { background: var(--blocked); }
</style>

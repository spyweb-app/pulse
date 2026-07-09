<template>
  <div class="modal-overlay" @click.self="$emit('cancel')">
    <div class="modal" style="max-width: 400px">
      <div class="modal-header">
        <h2 class="modal-title">{{ title }}</h2>
      </div>
      <div class="modal-body">
        <p class="confirm-message">{{ message }}</p>
        <div class="modal-actions">
          <button class="btn-ghost" @click="$emit('cancel')">Cancel</button>
          <button class="btn-danger" @click="$emit('confirm')">Delete</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  title: string
  message: string
}>()

defineEmits<{
  confirm: []
  cancel: []
}>()
</script>

<style scoped>
.modal-header {
  @apply px-6 py-5 border-b border-[var(--border)];
}

.modal-title {
  @apply text-lg font-semibold;
}

.modal-body {
  @apply p-6;
}

.confirm-message {
  @apply text-[var(--text-secondary)] text-sm leading-normal;
}

.modal-actions {
  @apply flex justify-end gap-2 mt-6;
}
</style>

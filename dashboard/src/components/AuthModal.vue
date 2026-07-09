<template>
  <Teleport to="body">
    <div class="modal-overlay" @click.self="close">
      <div class="auth-modal">
        <span class="auth-icon">&#128274;</span>
        <h3 class="auth-title">Authentication Required</h3>
        <p class="auth-desc">Please enter your API key to continue.</p>

        <input
          ref="inputRef"
          v-model="inputKey"
          type="password"
          class="input"
          placeholder="Enter API Key"
          @keyup.enter="submit"
        />

        <button class="auth-btn" @click="submit">Unlock Dashboard</button>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { setApiKey, apiKey, showAuthModal } from '~stores/auth'

const inputKey = ref('')
const inputRef = ref<HTMLInputElement | null>(null)

onMounted(() => {
  inputRef.value?.focus()
})

function submit() {
  if (!inputKey.value) return
  setApiKey(inputKey.value)
}

function close() {
  if (apiKey.value) showAuthModal.value = false
}
</script>

<style scoped>
.auth-modal {
  @apply bg-[var(--surface)] rounded-xl border border-[var(--border)] p-6 text-center;
  max-width: 400px;
  width: 100%;
  margin: 0 auto;
}

.auth-icon {
  @apply text-[48px] block mb-4;
  color: var(--accent);
}

.auth-title {
  @apply text-xl font-bold mb-2;
}

.auth-desc {
  @apply text-sm text-[var(--text-muted)] mb-5;
}

.input {
  @apply mb-5;
}

.auth-btn {
  @apply w-full rounded-lg py-3 px-4 font-semibold cursor-pointer transition-all duration-150;
  background: var(--accent);
  color: #fff;
  border: none;
}
.auth-btn:hover {
  background: var(--accent-hover);
}
</style>

<template>
  <header class="topbar">
    <h1 class="title">
      <span class="i-mdi-cog-outline text-[var(--accent)] mr-2" />
      Settings
    </h1>
  </header>

  <div class="content">
    <div class="settings-card">
      <div class="field">
        <label class="label">Instance Name</label>
        <input class="input" :class="{ invalid: errors.name }" v-model="instanceName" placeholder="PULSE" @input="clearError('name')" />
        <span class="help-text">Used in alert payloads and email subjects.</span>
        <span v-if="errors.name" class="field-error">{{ errors.name }}</span>
      </div>

      <div class="field-row">
        <div class="field flex-1">
          <label class="label">Retention Days</label>
          <input class="input" :class="{ invalid: errors.retention }" v-model.number="retentionDays" type="number" min="1" @input="clearError('retention')" />
          <span v-if="errors.retention" class="field-error">{{ errors.retention }}</span>
        </div>
        <div class="field flex-1">
          <label class="label">Alert Cooldown (sec)</label>
          <input class="input" :class="{ invalid: errors.cooldown }" v-model.number="cooldownSec" type="number" min="0" @input="clearError('cooldown')" />
          <span v-if="errors.cooldown" class="field-error">{{ errors.cooldown }}</span>
        </div>
      </div>

      <div class="field">
        <label class="label">Certificate Expiry Threshold (days)</label>
        <input class="input" v-model.number="certThresholdDays" type="number" min="1" max="365" />
        <span class="help-text">Default threshold for certificate expiry alerts. Can be overridden per monitor.</span>
      </div>

      <button class="btn-primary mt-4" @click="saveSettings">Save</button>
    </div>
  </div>
</template>

<script setup lang="ts">
defineOptions({ layout: 'default' })

import { ref, reactive, onMounted, watch } from 'vue'
import { api } from '~lib/api'
import { keyVersion } from '~stores/auth'
import { isNonEmpty } from '~lib/validators'
import { showNotification } from '~stores/app'

const instanceName = ref('')
const retentionDays = ref(90)
const cooldownSec = ref(300)
const certThresholdDays = ref(14)

const errors = reactive<Record<string, string>>({})

function clearError(field: string) {
  delete errors[field]
}

watch(keyVersion, () => {
  loadSettings()
})

async function loadSettings() {
  try {
    const s = await api.getSettings()
    instanceName.value = s.instance_name || 'PULSE'
    retentionDays.value = parseInt(s.retention_days) || 90
    cooldownSec.value = parseInt(s.alert_cooldown_sec) || 300
    certThresholdDays.value = parseInt(s.cert_threshold_days) || 14
  } catch (e: any) {
    console.error('Failed to load settings:', e.message)
  }
}

function validate(): boolean {
  Object.keys(errors).forEach(k => delete errors[k])

  if (!isNonEmpty(instanceName.value)) errors.name = 'Instance name is required'

  const days = Number(retentionDays.value)
  if (!Number.isInteger(days) || days < 1) errors.retention = 'Must be at least 1'

  const cooldown = Number(cooldownSec.value)
  if (!Number.isInteger(cooldown) || cooldown < 0) errors.cooldown = 'Must be 0 or more'

  return Object.keys(errors).length === 0
}

async function saveSettings() {
  if (!validate()) return
  try {
    await api.updateSettings({
      instance_name: instanceName.value,
      retention_days: String(retentionDays.value),
      alert_cooldown_sec: String(cooldownSec.value),
      cert_threshold_days: String(certThresholdDays.value),
    })
    showNotification('Settings saved', 'success')
  } catch (e: any) {
    showNotification(e.message || 'Failed to save settings', 'error')
  }
}

onMounted(() => {
  loadSettings()
})
</script>

<style scoped>
.topbar {
  @apply flex items-center justify-between px-7 py-5 border-b border-[var(--border)] bg-[var(--base)];
}

.title {
  @apply text-[22px] font-semibold tracking-[-0.3px];
}

.content {
  @apply flex-1 overflow-y-auto px-7 py-6;
}

.settings-card {
  @apply bg-[var(--surface)] border border-[var(--border)] rounded-xl p-6 max-w-[480px];
}

.field {
  @apply mb-4;
}

.field-row {
  @apply flex gap-3;
}

.help-text {
  @apply text-xs text-[var(--text-muted)] mt-1.5;
}

.field-error {
  @apply block text-[11px] text-[var(--down)] mt-1;
}

.input.invalid {
  border-color: var(--down);
}
</style>

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import UnoCSS from 'unocss/vite'

export default defineConfig({
  plugins: [vue(), UnoCSS()],
  build: { outDir: '../ui', emptyOutDir: true },
  server: {
    port: 5173,
    proxy: {
      '/api': 'http://localhost:8000'
    }
  },
  resolve: {
    extensions: ['.js', '.json', '.vue', '.sass', '.scss', '.css', '.ts'],
    alias: {
      '~': new URL('./', import.meta.url).pathname,
      '~com': new URL('./src/components', import.meta.url).pathname,
      '~pages': new URL('./src/pages', import.meta.url).pathname,
      '~layouts': new URL('./src/layouts', import.meta.url).pathname,
      '~stores': new URL('./src/stores', import.meta.url).pathname,
      '~composables': new URL('./src/composables', import.meta.url).pathname,
      '~lib': new URL('./src/lib', import.meta.url).pathname,
    },
  },
})

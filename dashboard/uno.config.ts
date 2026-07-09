import { defineConfig, presetWind3 } from 'unocss'
import presetIcons from '@unocss/preset-icons'
import transformerDirectives from '@unocss/transformer-directives'

export default defineConfig({
  presets: [
    presetWind3(),
    presetIcons({
      scale: 1.2,
      extraProperties: { display: 'inline-block' },
    }) as any,
  ],
  transformers: [transformerDirectives()],
})

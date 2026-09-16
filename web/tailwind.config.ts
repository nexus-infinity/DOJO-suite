import type { Config } from 'tailwindcss'
import { BRAND_KIT } from './lib/brandKit'

const config: Config = {
  content: [
    './app/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './lib/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        // Brand Kit — Default Surface Profile (Future Path)
        void:    BRAND_KIT.canvas,
        canvas:  BRAND_KIT.canvas,
        surface: BRAND_KIT.deepTeal,
        raised:  '#123838',
        border:  BRAND_KIT.structure,
        structure: BRAND_KIT.structure,
        wireframe: BRAND_KIT.wireframe,
        energy:  BRAND_KIT.activeEnergy,
        wisdom:  BRAND_KIT.wisdomDot,
        // Text scale
        muted:   BRAND_KIT.textSecondary,
        dim:     BRAND_KIT.structure,
        // Chamber Accent Base — Brand Kit GOLDEN
        dojo:    BRAND_KIT.chambers.dojo,
        obiwan:  BRAND_KIT.chambers.obiwan,
        atlas:   BRAND_KIT.chambers.atlas,
        tata:    BRAND_KIT.chambers.tata,
        akron:   BRAND_KIT.chambers.akron,
        arkadas: BRAND_KIT.chambers.arkadas,
        kings:   BRAND_KIT.chambers.kings,
      },
      fontFamily: {
        mono: ['JetBrains Mono', 'Fira Code', 'ui-monospace', 'monospace'],
        sans: ['Inter', 'ui-sans-serif', 'system-ui'],
      },
      animation: {
        'spin-slow':   'spin 8s linear infinite',
        'spin-medium': 'spin 4s linear infinite',
        'pulse-glow':  'pulse 2s cubic-bezier(0.4,0,0.6,1) infinite',
        'portal-in':   'portalIn 0.6s cubic-bezier(0.34,1.56,0.64,1) forwards',
      },
      keyframes: {
        portalIn: {
          '0%':   { opacity: '0', transform: 'scale(0.85) rotate(-12deg)' },
          '100%': { opacity: '1', transform: 'scale(1) rotate(0deg)' },
        },
      },
    },
  },
  plugins: [require('@tailwindcss/typography')],
}

export default config

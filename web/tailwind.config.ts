import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './app/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './lib/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        // FIELD void palette — "Days of Future Past"
        void:    '#05050A',
        surface: '#0F0F1A',
        raised:  '#1A1A2E',
        border:  '#2A2A40',
        // Chamber tech palette
        dojo:    '#7C3AED',
        obiwan:  '#E2E8F0',
        atlas:   '#06B6D4',
        tata:    '#F59E0B',
        akron:   '#78716C',
        arkadas: '#EAB308',
        kings:   '#F43F5E',
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
  plugins: [],
}

export default config

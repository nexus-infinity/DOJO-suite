import type { NextConfig } from 'next'

// This app is the ◼︎ DOJO overview manifestation. Do not let Turbopack
// walk up to /Users/field/package-lock.json (unowned FIELD-home npm nest).
const nextConfig: NextConfig = {
  turbopack: {
    root: __dirname,
  },
}

export default nextConfig

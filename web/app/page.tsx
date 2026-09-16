// FIELD — Public landing surface
// Brand Kit Future Path canvas. Sacred geometry. No marketing language.

import Link from 'next/link'
import { BRAND_KIT } from '@/lib/brandKit'

export const metadata = {
  title: 'FIELD',
  description: '● Field System — sovereign intelligence architecture',
}

export default function LandingPage() {
  const text = BRAND_KIT.textPrimary
  const canvas = BRAND_KIT.canvas
  const structure = BRAND_KIT.structure

  return (
    <div
      className="relative min-h-screen overflow-hidden"
      style={{ background: canvas, color: text }}
    >
      {/* Metatron ambient background — structure trace opacity */}
      <div
        className="absolute inset-0 flex items-center justify-center pointer-events-none select-none"
        aria-hidden="true"
      >
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img
          src="/metatron_field.svg"
          alt=""
          className="w-full max-w-4xl opacity-[0.07] scale-110"
          style={{ filter: 'blur(0.5px)' }}
        />
      </div>

      {/* Main content */}
      <div className="relative z-10 flex flex-col min-h-screen">
        <main className="flex-1 flex flex-col items-center justify-center px-6 py-24">
          <div className="mb-20 text-center">
            <h1
              className="text-[clamp(4rem,12vw,9rem)] font-light tracking-[0.35em]"
              style={{
                fontFamily: 'ui-sans-serif, system-ui, sans-serif',
                letterSpacing: '0.4em',
                color: text,
              }}
            >
              FIELD
            </h1>
            <p
              className="mt-4 text-sm tracking-[0.25em] opacity-40"
              style={{ fontFamily: 'ui-monospace, monospace', color: BRAND_KIT.textSecondary }}
            >
              ● Field System — observer mode active
            </p>
          </div>

          <div className="flex flex-col sm:flex-row gap-12 sm:gap-20 items-center sm:items-start">
            <SurfaceNode
              symbol="●"
              name="OBI-WAN"
              descriptor="Pattern observation"
              color={BRAND_KIT.chambers.obiwan}
              freq="963"
            />
            <SurfaceNode
              symbol="▲"
              name="ATLAS"
              descriptor="Knowledge architecture"
              color={BRAND_KIT.chambers.atlas}
              freq="528"
            />
            <SurfaceNode
              symbol="◼"
              name="DOJO"
              descriptor="Manifestation in progress"
              color={BRAND_KIT.chambers.dojo}
              freq="741"
            />
          </div>
        </main>

        <footer
          className="relative z-10 flex flex-col sm:flex-row items-center justify-between px-8 py-6"
          style={{ borderTop: `1px solid color-mix(in srgb, ${structure} 40%, transparent)` }}
        >
          <span
            className="opacity-30 text-sm tracking-widest"
            style={{ fontFamily: 'ui-monospace, monospace', color: text }}
          >
            ● Field System
          </span>
          <div className="flex gap-6 mt-3 sm:mt-0">
            <a
              href="mailto:jeremy.rich@berjak.com.au"
              className="opacity-25 text-xs tracking-wider hover:opacity-40 transition-opacity"
              style={{ fontFamily: 'ui-monospace, monospace', color: text }}
            >
              jeremy.rich@berjak.com.au
            </a>
            <a
              href="https://berjak.com.au"
              className="opacity-25 text-xs tracking-wider hover:opacity-40 transition-opacity"
              style={{ fontFamily: 'ui-monospace, monospace', color: text }}
            >
              berjak.com.au
            </a>
          </div>
          <nav className="flex gap-6 mt-3 sm:mt-0">
            <Link
              href="/comms"
              className="opacity-20 text-xs tracking-widest hover:opacity-40 transition-opacity uppercase"
              style={{ fontFamily: 'ui-monospace, monospace', color: text }}
            >
              Comms
            </Link>
            <Link
              href="/status"
              className="opacity-20 text-xs tracking-widest hover:opacity-40 transition-opacity uppercase"
              style={{ fontFamily: 'ui-monospace, monospace', color: text }}
            >
              Status
            </Link>
          </nav>
        </footer>
      </div>
    </div>
  )
}

function SurfaceNode({
  symbol,
  name,
  descriptor,
  color,
  freq,
}: {
  symbol: string
  name: string
  descriptor: string
  color: string
  freq: string
}) {
  return (
    <div className="flex flex-col items-center gap-3 text-center group">
      <span
        className="text-3xl opacity-70 group-hover:opacity-90 transition-opacity"
        style={{ color, fontFamily: 'ui-sans-serif, serif' }}
        aria-hidden="true"
      >
        {symbol}
      </span>

      <span
        className="text-sm font-medium tracking-[0.2em] opacity-80"
        style={{ fontFamily: 'ui-monospace, monospace', color: BRAND_KIT.textPrimary }}
      >
        {name}
      </span>

      <span
        className="text-xs tracking-wider opacity-35"
        style={{ fontFamily: 'ui-monospace, monospace', color: BRAND_KIT.textSecondary }}
      >
        {descriptor}
      </span>

      <span
        className="text-[10px] opacity-40 tracking-widest mt-1"
        style={{ color, fontFamily: 'ui-monospace, monospace' }}
      >
        {freq} Hz
      </span>
    </div>
  )
}

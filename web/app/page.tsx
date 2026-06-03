// FIELD — Public landing surface
// Dark mode only. Sacred geometry. No marketing language.

import Link from 'next/link'

export const metadata = {
  title: 'FIELD',
  description: '● Field System — sovereign intelligence architecture',
}

export default function LandingPage() {
  return (
    <div className="relative min-h-screen bg-[#0a0a0a] text-[#f5f5f0] overflow-hidden">
      {/* Metatron ambient background */}
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
        {/* Center wordmark section */}
        <main className="flex-1 flex flex-col items-center justify-center px-6 py-24">
          {/* FIELD wordmark */}
          <div className="mb-20 text-center">
            <h1
              className="text-[clamp(4rem,12vw,9rem)] font-light tracking-[0.35em] text-[#f5f5f0]"
              style={{ fontFamily: 'ui-sans-serif, system-ui, sans-serif', letterSpacing: '0.4em' }}
            >
              FIELD
            </h1>
            <p
              className="mt-4 text-[#e8e4d9] text-sm tracking-[0.25em] opacity-40"
              style={{ fontFamily: 'ui-monospace, monospace' }}
            >
              ● Field System — observer mode active
            </p>
          </div>

          {/* Three surface nodes */}
          <div className="flex flex-col sm:flex-row gap-12 sm:gap-20 items-center sm:items-start">
            <SurfaceNode symbol="●" name="OBI-WAN" descriptor="Pattern observation" color="#9370DB" freq="963" />
            <SurfaceNode symbol="▲" name="ATLAS" descriptor="Knowledge architecture" color="#FFD700" freq="528" />
            <SurfaceNode symbol="◼" name="DOJO" descriptor="Manifestation in progress" color="#4488ff" freq="741" />
          </div>
        </main>

        {/* Footer */}
        <footer className="relative z-10 flex flex-col sm:flex-row items-center justify-between px-8 py-6 border-t border-[#1a1a1a]">
          <span
            className="text-[#f5f5f0] opacity-30 text-sm tracking-widest"
            style={{ fontFamily: 'ui-monospace, monospace' }}
          >
            ● Field System
          </span>
          <div className="flex gap-6 mt-3 sm:mt-0">
            <a
              href="mailto:jeremy.rich@berjak.com.au"
              className="text-[#f5f5f0] opacity-25 text-xs tracking-wider hover:opacity-40 transition-opacity"
              style={{ fontFamily: 'ui-monospace, monospace' }}
            >
              jeremy.rich@berjak.com.au
            </a>
            <a
              href="https://berjak.com.au"
              className="text-[#f5f5f0] opacity-25 text-xs tracking-wider hover:opacity-40 transition-opacity"
              style={{ fontFamily: 'ui-monospace, monospace' }}
            >
              berjak.com.au
            </a>
          </div>
          <nav className="flex gap-6 mt-3 sm:mt-0">
            <Link
              href="/comms"
              className="text-[#f5f5f0] opacity-20 text-xs tracking-widest hover:opacity-40 transition-opacity uppercase"
              style={{ fontFamily: 'ui-monospace, monospace' }}
            >
              Comms
            </Link>
            <Link
              href="/status"
              className="text-[#f5f5f0] opacity-20 text-xs tracking-widest hover:opacity-40 transition-opacity uppercase"
              style={{ fontFamily: 'ui-monospace, monospace' }}
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
      {/* Symbol */}
      <span
        className="text-3xl opacity-70 group-hover:opacity-90 transition-opacity"
        style={{ color, fontFamily: 'ui-sans-serif, serif' }}
        aria-hidden="true"
      >
        {symbol}
      </span>

      {/* Name */}
      <span
        className="text-sm font-medium tracking-[0.2em] text-[#f5f5f0] opacity-80"
        style={{ fontFamily: 'ui-monospace, monospace' }}
      >
        {name}
      </span>

      {/* Descriptor */}
      <span
        className="text-xs tracking-wider text-[#f5f5f0] opacity-35"
        style={{ fontFamily: 'ui-monospace, monospace' }}
      >
        {descriptor}
      </span>

      {/* Frequency */}
      <span
        className="text-[10px] opacity-20 tracking-widest mt-1"
        style={{ color, fontFamily: 'ui-monospace, monospace' }}
      >
        {freq} Hz
      </span>
    </div>
  )
}

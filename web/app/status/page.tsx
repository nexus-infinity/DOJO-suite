// FIELD — /status
// Live system status board. Read-only. Auto-refreshes every 60s.
// No write operations from public surface.

'use client'

import { useCallback, useEffect, useState } from 'react'
import Link from 'next/link'

interface ChamberHealth {
  chamber: string
  port: number
  frequency: number
  normalizedStatus: 'alive' | 'degraded' | 'offline'
  score: number
  role?: string
}

interface HealthPayload {
  timestamp: string
  chambers: Record<string, ChamberHealth>
  alive: number
  total: number
  bear?: {
    score: number
    label: string
  }
}

interface ChamberDef {
  key: string
  symbol: string
  name: string
  port: number
  freq: number
  color: string
  role: string
}

// Static chamber definitions — mirrors lib/chambers.ts
const CHAMBERS: ChamberDef[] = [
  { key: 'dojo',    symbol: '◼', name: 'DOJO',         port: 7410, freq: 741,  color: '#7C3AED', role: 'Manifestation apex' },
  { key: 'obiwan',  symbol: '●', name: 'OBI-WAN',       port: 9630, freq: 963,  color: '#9370DB', role: 'Observer consciousness' },
  { key: 'atlas',   symbol: '▲', name: 'ATLAS',         port: 5280, freq: 528,  color: '#FFD700', role: 'Crystalline validation' },
  { key: 'tata',    symbol: '▼', name: 'TATA',          port: 4320, freq: 432,  color: '#FF8C00', role: 'Temporal truth' },
  { key: 'akron',   symbol: '◻', name: 'AKRON',         port: 3960, freq: 396,  color: '#78716C', role: 'Archive sovereignty' },
  { key: 'arkadas', symbol: '◉', name: 'ARKADAŞ',       port: 7170, freq: 717,  color: '#EAB308', role: 'Embodiment bridge (SPIN)' },
  { key: 'kings',   symbol: '◎', name: 'Kings Chamber', port: 8520, freq: 852,  color: '#F43F5E', role: 'Infrastructure routing' },
]

// Spoke lock status — static (training complete)
const SPOKE_LOCKS: Record<string, { locked: boolean; label: string }> = {
  AKRON:   { locked: true,  label: '6/6 LOCKED' },
  ATLAS:   { locked: true,  label: '6/6 LOCKED' },
  TATA:    { locked: true,  label: '6/6 LOCKED' },
  'OBI-WAN': { locked: true, label: '6/6 LOCKED' },
  ARKADAŞ: { locked: true,  label: '6/6 LOCKED' },
  DOJO:    { locked: false, label: 'IN TRAINING' },
}

export default function StatusPage() {
  const [health, setHealth] = useState<HealthPayload | null>(null)
  const [loading, setLoading] = useState(true)
  const [lastFetched, setLastFetched] = useState<string>('')
  const [countdown, setCountdown] = useState(60)

  const fetchHealth = useCallback(async () => {
    try {
      const res = await fetch('/api/health', { cache: 'no-store' })
      if (res.ok) {
        const data = await res.json()
        setHealth(data)
      }
    } catch {
      // Silently degrade — show cached or nothing
    } finally {
      setLoading(false)
      setLastFetched(new Date().toISOString())
      setCountdown(60)
    }
  }, [])

  useEffect(() => {
    fetchHealth()
    const interval = setInterval(fetchHealth, 60_000)
    return () => clearInterval(interval)
  }, [fetchHealth])

  // Countdown tick
  useEffect(() => {
    const tick = setInterval(() => {
      setCountdown(c => (c > 0 ? c - 1 : 0))
    }, 1_000)
    return () => clearInterval(tick)
  }, [lastFetched])

  return (
    <div className="min-h-screen bg-[#0a0a0a] text-[#f5f5f0]">
      {/* Header */}
      <header className="border-b border-[#1a1a1a] px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link
            href="/"
            className="text-[#f5f5f0] opacity-30 text-xs tracking-widest hover:opacity-50 transition-opacity uppercase"
            style={{ fontFamily: 'ui-monospace, monospace' }}
          >
            ← FIELD
          </Link>
          <span className="opacity-10">|</span>
          <span
            className="text-[#f5f5f0] opacity-60 text-xs tracking-widest uppercase"
            style={{ fontFamily: 'ui-monospace, monospace' }}
          >
            Status
          </span>
        </div>
        <div className="flex items-center gap-4">
          <span
            className="text-[#f5f5f0] opacity-20 text-[10px] tracking-wider"
            style={{ fontFamily: 'ui-monospace, monospace' }}
          >
            refresh in {countdown}s
          </span>
          <Link
            href="/comms"
            className="text-[#f5f5f0] opacity-20 text-xs tracking-widest hover:opacity-40 transition-opacity uppercase"
            style={{ fontFamily: 'ui-monospace, monospace' }}
          >
            Comms →
          </Link>
        </div>
      </header>

      <main className="max-w-4xl mx-auto px-6 py-16">
        {/* Page heading */}
        <div className="mb-16">
          <h1
            className="text-2xl font-light tracking-[0.2em] text-[#f5f5f0] opacity-80 mb-3"
            style={{ fontFamily: 'ui-sans-serif, system-ui, sans-serif' }}
          >
            System Status
          </h1>
          {lastFetched && (
            <p
              className="text-xs text-[#f5f5f0] opacity-25 tracking-wider"
              style={{ fontFamily: 'ui-monospace, monospace' }}
            >
              Last checked: {new Date(lastFetched).toLocaleTimeString('en-AU', { hour12: false })}
            </p>
          )}
        </div>

        {/* Bear score */}
        {health?.bear && (
          <div className="mb-12 p-4 border border-[#1a1a1a]">
            <div className="flex items-center justify-between">
              <span
                className="text-[10px] tracking-widest text-[#f5f5f0] opacity-30 uppercase"
                style={{ fontFamily: 'ui-monospace, monospace' }}
              >
                Homeostasis Index
              </span>
              <div className="flex items-center gap-3">
                <span
                  className="text-xs tracking-wider"
                  style={{
                    fontFamily: 'ui-monospace, monospace',
                    color: health.bear.score >= 0.9 ? '#00CC66' : health.bear.score >= 0.75 ? '#FF8C00' : '#CC0000',
                  }}
                >
                  {(health.bear.score * 100).toFixed(1)}%
                </span>
                <span
                  className="text-[10px] tracking-widest text-[#f5f5f0] opacity-30 uppercase"
                  style={{ fontFamily: 'ui-monospace, monospace' }}
                >
                  {health.bear.label}
                </span>
              </div>
            </div>
          </div>
        )}

        {/* Chambers grid */}
        <section className="mb-16">
          <h2
            className="text-[10px] tracking-widest text-[#f5f5f0] opacity-30 mb-6 uppercase"
            style={{ fontFamily: 'ui-monospace, monospace' }}
          >
            Chambers — {health ? `${health.alive}/${health.total} alive` : '—'}
          </h2>

          <div className="flex flex-col gap-3">
            {CHAMBERS.map((chamber) => {
              const live = health?.chambers?.[chamber.key] as ChamberHealth | undefined
              const status = loading ? 'checking' : (live?.normalizedStatus ?? 'offline')
              return (
                <ChamberRow
                  key={chamber.key}
                  chamber={chamber}
                  status={status as 'alive' | 'degraded' | 'offline' | 'checking'}
                />
              )
            })}
          </div>
        </section>

        {/* Spoke training locks */}
        <section className="mb-16">
          <h2
            className="text-[10px] tracking-widest text-[#f5f5f0] opacity-30 mb-6 uppercase"
            style={{ fontFamily: 'ui-monospace, monospace' }}
          >
            Training Gates — Geometric Validation
          </h2>

          <div className="flex flex-col gap-3">
            {Object.entries(SPOKE_LOCKS).map(([name, lock]) => (
              <div
                key={name}
                className="flex items-center justify-between px-4 py-3 border border-[#1a1a1a]"
              >
                <span
                  className="text-xs text-[#f5f5f0] opacity-60 tracking-wider"
                  style={{ fontFamily: 'ui-monospace, monospace' }}
                >
                  {name}
                </span>
                <div className="flex items-center gap-2">
                  <span
                    className="text-xs tracking-wider"
                    style={{
                      fontFamily: 'ui-monospace, monospace',
                      color: lock.locked ? '#00CC66' : '#FF8C00',
                    }}
                  >
                    {lock.locked ? '✓' : '⚡'}
                  </span>
                  <span
                    className="text-[10px] tracking-widest opacity-50"
                    style={{
                      fontFamily: 'ui-monospace, monospace',
                      color: lock.locked ? '#00CC66' : '#FF8C00',
                    }}
                  >
                    {lock.label}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </section>

        {/* Correspondence gate */}
        <section>
          <h2
            className="text-[10px] tracking-widest text-[#f5f5f0] opacity-30 mb-6 uppercase"
            style={{ fontFamily: 'ui-monospace, monospace' }}
          >
            Correspondence Gate
          </h2>
          <div className="flex items-center justify-between px-4 py-4 border border-[#1a1a1a]">
            <span
              className="text-xs text-[#f5f5f0] opacity-50 tracking-wider"
              style={{ fontFamily: 'ui-monospace, monospace' }}
            >
              Active lanes
            </span>
            <div className="flex items-center gap-3">
              <span
                className="text-sm tracking-wider text-[#FF8C00]"
                style={{ fontFamily: 'ui-monospace, monospace' }}
              >
                4
              </span>
              <span
                className="text-[10px] tracking-widest text-[#FF8C00] opacity-60"
                style={{ fontFamily: 'ui-monospace, monospace' }}
              >
                PENDING
              </span>
            </div>
          </div>
          <div className="mt-3 flex justify-end">
            <Link
              href="/comms"
              className="text-[10px] tracking-widest text-[#f5f5f0] opacity-20 hover:opacity-40 transition-opacity uppercase"
              style={{ fontFamily: 'ui-monospace, monospace' }}
            >
              View lanes →
            </Link>
          </div>
        </section>
      </main>
    </div>
  )
}

function ChamberRow({
  chamber,
  status,
}: {
  chamber: ChamberDef
  status: 'alive' | 'degraded' | 'offline' | 'checking'
}) {
  const statusColor =
    status === 'alive' ? '#00CC66'
    : status === 'degraded' ? '#FF8C00'
    : status === 'checking' ? '#64748b'
    : '#CC0000'

  const statusLabel =
    status === 'alive' ? 'ALIVE'
    : status === 'degraded' ? 'DEGRADED'
    : status === 'checking' ? '—'
    : 'OFFLINE'

  return (
    <div className="flex items-center justify-between px-4 py-3 border border-[#1a1a1a] hover:border-[#2a2a2a] transition-colors">
      {/* Left: symbol + name + role */}
      <div className="flex items-center gap-3 min-w-0">
        <span
          className="text-base shrink-0"
          style={{ color: chamber.color, fontFamily: 'ui-sans-serif, serif' }}
        >
          {chamber.symbol}
        </span>
        <div className="min-w-0">
          <span
            className="text-xs text-[#f5f5f0] opacity-70 tracking-wider"
            style={{ fontFamily: 'ui-monospace, monospace' }}
          >
            {chamber.name}
          </span>
          <span
            className="ml-2 text-[10px] text-[#f5f5f0] opacity-25 tracking-wide hidden sm:inline"
            style={{ fontFamily: 'ui-monospace, monospace' }}
          >
            {chamber.role}
          </span>
        </div>
      </div>

      {/* Right: port + freq + status */}
      <div className="flex items-center gap-4 shrink-0">
        <span
          className="text-[10px] text-[#f5f5f0] opacity-25 tracking-wider hidden sm:block"
          style={{ fontFamily: 'ui-monospace, monospace' }}
        >
          :{chamber.port}
        </span>
        <span
          className="text-[10px] tracking-wider opacity-25 hidden sm:block"
          style={{ color: chamber.color, fontFamily: 'ui-monospace, monospace' }}
        >
          {chamber.freq} Hz
        </span>
        <div className="flex items-center gap-1.5">
          <span
            className="w-1.5 h-1.5 rounded-full"
            style={{ backgroundColor: statusColor }}
          />
          <span
            className="text-[10px] tracking-widest"
            style={{ color: statusColor, fontFamily: 'ui-monospace, monospace' }}
          >
            {statusLabel}
          </span>
        </div>
      </div>
    </div>
  )
}

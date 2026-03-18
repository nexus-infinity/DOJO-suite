'use client'

import { useEffect, useMemo, useState } from 'react'
import { CHAMBERS, type ChamberKey } from '@/lib/chambers'
import { SpellCircle, BEARRing } from './SpellCircle'
import { type SessionRecord, formatRelativeSessionTime } from '@/lib/sessionStore'

interface HealthPayload {
  chambers: Record<string, {
    normalizedStatus?: 'alive' | 'degraded' | 'offline'
    score?: number
  }>
  bear?: {
    score: number
    label?: string
  }
}

interface Props {
  sessions: SessionRecord[]
  activeSessionId: string
  onSelectSession: (sessionId: string) => void
  onNewSession: () => void
}

const CHAMBER_KEYS: ChamberKey[] = ['dojo', 'obiwan', 'atlas', 'tata', 'akron', 'arkadas', 'kings']

export function ChamberSidebar({ sessions, activeSessionId, onSelectSession, onNewSession }: Props) {
  const [collapsed, setCollapsed] = useState(false)
  const [health, setHealth] = useState<HealthPayload | null>(null)

  useEffect(() => {
    let cancelled = false

    async function loadHealth() {
      try {
        const res = await fetch('/api/health', { cache: 'no-store' })
        if (!res.ok) throw new Error(`HTTP ${res.status}`)
        const json = await res.json()
        if (!cancelled) setHealth(json)
      } catch {
        if (!cancelled) setHealth(null)
      }
    }

    loadHealth()
    const interval = window.setInterval(loadHealth, 15_000)
    return () => {
      cancelled = true
      window.clearInterval(interval)
    }
  }, [])

  const sortedSessions = useMemo(
    () => [...sessions].sort((a, b) => Date.parse(b.updatedAt) - Date.parse(a.updatedAt)),
    [sessions]
  )

  if (collapsed) {
    return (
      <aside className="w-12 border-r border-border bg-surface flex flex-col items-center py-3 gap-3">
        <button onClick={() => setCollapsed(false)} className="text-muted hover:text-slate-300 text-lg">☰</button>
        <div className="flex-1 flex flex-col items-center gap-2 mt-4">
          {CHAMBER_KEYS.map(key => (
            <div key={key} title={`${CHAMBERS[key].symbol} ${CHAMBERS[key].name} :${CHAMBERS[key].port}`}>
              <SpellCircle chamber={key} size={24} compact active={health?.chambers?.[key]?.normalizedStatus === 'alive'} />
            </div>
          ))}
        </div>
      </aside>
    )
  }

  return (
    <aside className="w-56 shrink-0 border-r border-border bg-surface flex flex-col">

      {/* Logo + collapse */}
      <div className="flex items-center justify-between px-3 py-3 border-b border-border">
        <div className="flex items-center gap-2">
          <SpellCircle chamber="kings" size={24} compact />
          <span className="text-sm font-semibold text-slate-200 font-mono">FIELD</span>
        </div>
        <button onClick={() => setCollapsed(true)} className="text-muted hover:text-slate-300">‹</button>
      </div>

      {/* Chamber health strip */}
      <div className="px-3 py-2.5 border-b border-border">
        <p className="text-xs text-dim font-mono mb-2">Mac Studio chambers</p>
        <div className="space-y-1.5">
          {CHAMBER_KEYS.map(key => {
            const ch = CHAMBERS[key]
            const state = health?.chambers?.[key]
            const alive = state?.normalizedStatus === 'alive'
            const degraded = state?.normalizedStatus === 'degraded'
            return (
              <div key={key} className="flex items-center gap-2">
                <SpellCircle chamber={key} size={18} compact active={alive} />
                <span className="text-xs font-mono text-muted flex-1">{ch.symbol} {ch.name}</span>
                <span className={`text-xs font-mono ${
                  alive ? 'text-green-400' : degraded ? 'text-amber-400' : 'text-red-400/70'
                }`}>
                  {alive ? '●' : degraded ? '◐' : '○'}
                </span>
              </div>
            )
          })}
        </div>
      </div>

      {/* BEAR score — compact */}
      <div className="flex items-center justify-center py-3 border-b border-border">
        <div className="flex flex-col items-center gap-1">
          <BEARRing score={health?.bear?.score ?? 0} size={64} />
          <span className="text-[10px] font-mono uppercase tracking-wider text-dim">
            {health?.bear?.label ?? 'offline'}
          </span>
        </div>
      </div>

      {/* New conversation */}
      <div className="px-3 py-2.5">
        <button
          onClick={onNewSession}
          className="w-full flex items-center gap-2 px-3 py-2 bg-dojo/15 hover:bg-dojo/25 border border-dojo/20 rounded-lg text-sm text-dojo font-medium transition-all"
        >
          <span>+</span>
          <span>New conversation</span>
        </button>
      </div>

      {/* History */}
      <div className="flex-1 overflow-y-auto px-2 pb-2">
        <p className="text-xs text-dim font-mono px-2 py-1.5">Recent</p>
        <div className="space-y-0.5">
          {sortedSessions.map(entry => (
            <button
              key={entry.id}
              onClick={() => onSelectSession(entry.id)}
              className={`w-full text-left px-2.5 py-2 rounded-lg group transition-colors ${
                activeSessionId === entry.id ? 'bg-dojo/10 border border-dojo/20' : 'hover:bg-raised'
              }`}
            >
              <div className="flex items-start gap-2">
                <span className="text-dim text-xs mt-0.5 shrink-0">
                  {entry.mode === 'chat' ? '◈' : entry.mode === 'code' ? '⟨⟩' : '⬡'}
                </span>
                <div className="min-w-0">
                  <p className="text-xs text-slate-300 group-hover:text-slate-100 truncate leading-snug">{entry.title}</p>
                  <p className="text-xs text-dim">{formatRelativeSessionTime(entry.updatedAt)}</p>
                </div>
              </div>
            </button>
          ))}
          {sortedSessions.length === 0 && (
            <p className="px-2.5 py-2 text-xs text-dim">No saved sessions yet</p>
          )}
        </div>
      </div>
    </aside>
  )
}

'use client'

import { useMemo, useState } from 'react'
import { SpellCircle } from './SpellCircle'
import { type SessionRecord, formatRelativeSessionTime } from '@/lib/sessionStore'

interface Props {
  sessions: SessionRecord[]
  activeSessionId: string
  activeMode: SessionRecord['mode'] | 'foreman'
  onSelectSession: (sessionId: string) => void
  onNewSession: () => void
  onSelectMode: (mode: SessionRecord['mode'] | 'foreman') => void
}

const WORK_MODES = [
  { id: 'chat', label: 'Chat', glyph: '◈' },
  { id: 'collab', label: 'Memory', glyph: '◫' },
  { id: 'foreman', label: 'Comms', glyph: '⊗' },
] as const

export function ChamberSidebar({
  sessions,
  activeSessionId,
  activeMode,
  onSelectSession,
  onNewSession,
  onSelectMode,
}: Props) {
  const [collapsed, setCollapsed] = useState(false)

  const sortedSessions = useMemo(
    () => [...sessions].sort((a, b) => Date.parse(b.updatedAt) - Date.parse(a.updatedAt)),
    [sessions]
  )

  if (collapsed) {
    return (
      <aside className="w-12 border-r border-border bg-surface flex flex-col items-center py-3 gap-3">
        <button onClick={() => setCollapsed(false)} className="text-muted hover:text-slate-300 text-lg">☰</button>
        <button
          onClick={onNewSession}
          title="New conversation"
          className="flex h-8 w-8 items-center justify-center rounded-lg bg-dojo/15 text-dojo hover:bg-dojo/25"
        >
          +
        </button>
      </aside>
    )
  }

  return (
    <aside className="w-60 shrink-0 border-r border-border bg-surface flex flex-col">

      {/* Logo + collapse */}
      <div className="flex items-center justify-between px-3 py-3 border-b border-border">
        <div className="flex items-center gap-2">
          <SpellCircle chamber="dojo" size={24} compact />
          <div>
            <span className="block text-sm font-semibold text-slate-200 font-mono">DOJO</span>
            <span className="block text-[10px] font-mono uppercase tracking-wide text-dim">Conversations</span>
          </div>
        </div>
        <button onClick={() => setCollapsed(true)} className="text-muted hover:text-slate-300">‹</button>
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

      <div className="px-3 pb-2">
        <p className="px-1 pb-2 text-xs font-mono text-dim">Modes</p>
        <div className="grid grid-cols-2 gap-2">
          {WORK_MODES.map(item => (
            <button
              key={item.id}
              onClick={() => onSelectMode(item.id)}
              className={`rounded-lg border px-3 py-2 text-left transition-all ${
                activeMode === item.id
                  ? 'border-dojo/30 bg-dojo/10 text-dojo'
                  : 'border-border bg-raised text-slate-300 hover:border-slate-600 hover:text-slate-100'
              }`}
            >
              <div className="text-xs font-mono">{item.glyph}</div>
              <div className="mt-1 text-xs font-medium">{item.label}</div>
            </button>
          ))}
        </div>
      </div>

      <div className="px-3 pb-2">
        <div className="rounded-lg border border-border bg-raised px-3 py-3">
          <p className="mb-2 text-xs font-mono text-dim">Live now</p>
          <div className="space-y-2 text-xs text-slate-300">
            <div>• session history and saved conversations</div>
            <div>• archive + personal memory surfaces</div>
            <div>• comms mode with real Berjak Gmail send path</div>
            <div>• Hugging Face job-status checks</div>
          </div>
        </div>
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

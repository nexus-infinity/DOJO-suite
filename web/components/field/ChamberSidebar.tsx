'use client'

import { useState } from 'react'
import { CHAMBERS, type ChamberKey } from '@/lib/chambers'
import { SpellCircle, BEARRing } from './SpellCircle'

// Left sidebar — conversation history + live chamber status

interface ConversationEntry {
  id: string
  title: string
  mode: 'chat' | 'code' | 'collab'
  updatedAt: string
}

const MOCK_HISTORY: ConversationEntry[] = [
  { id: '1', title: 'Niama training dataset review', mode: 'chat',  updatedAt: 'Today' },
  { id: '2', title: 'Swift MCP client scaffold',    mode: 'code',  updatedAt: 'Today' },
  { id: '3', title: 'Response Advantage S0-S7',     mode: 'collab',updatedAt: 'Yesterday' },
  { id: '4', title: 'Kit Car T0-T5 HUD design',     mode: 'code',  updatedAt: 'Yesterday' },
  { id: '5', title: 'BEAR coherence review',        mode: 'chat',  updatedAt: 'Feb 28' },
]

const CHAMBER_KEYS: ChamberKey[] = ['dojo', 'obiwan', 'atlas', 'tata', 'akron']

export function ChamberSidebar() {
  const [collapsed, setCollapsed] = useState(false)
  // Mock status — real data comes from /api/health in production
  const [chamberAlive] = useState<Record<string, boolean>>({
    dojo: true, obiwan: true, atlas: true, tata: false, akron: true
  })

  if (collapsed) {
    return (
      <aside className="w-12 border-r border-border bg-surface flex flex-col items-center py-3 gap-3">
        <button onClick={() => setCollapsed(false)} className="text-muted hover:text-slate-300 text-lg">☰</button>
        <div className="flex-1 flex flex-col items-center gap-2 mt-4">
          {CHAMBER_KEYS.map(key => (
            <div key={key} title={`${CHAMBERS[key].symbol} ${CHAMBERS[key].name} :${CHAMBERS[key].port}`}>
              <SpellCircle chamber={key} size={24} compact active={chamberAlive[key]} />
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
            const alive = chamberAlive[key]
            return (
              <div key={key} className="flex items-center gap-2">
                <SpellCircle chamber={key} size={18} compact active={alive} />
                <span className="text-xs font-mono text-muted flex-1">{ch.symbol} {ch.name}</span>
                <span className={`text-xs font-mono ${alive ? 'text-green-400' : 'text-red-400/70'}`}>
                  {alive ? '●' : '○'}
                </span>
              </div>
            )
          })}
        </div>
      </div>

      {/* BEAR score — compact */}
      <div className="flex items-center justify-center py-3 border-b border-border">
        <BEARRing score={0.87} size={64} />
      </div>

      {/* New conversation */}
      <div className="px-3 py-2.5">
        <button className="w-full flex items-center gap-2 px-3 py-2 bg-dojo/15 hover:bg-dojo/25 border border-dojo/20 rounded-lg text-sm text-dojo font-medium transition-all">
          <span>+</span>
          <span>New conversation</span>
        </button>
      </div>

      {/* History */}
      <div className="flex-1 overflow-y-auto px-2 pb-2">
        <p className="text-xs text-dim font-mono px-2 py-1.5">Recent</p>
        <div className="space-y-0.5">
          {MOCK_HISTORY.map(entry => (
            <button
              key={entry.id}
              className="w-full text-left px-2.5 py-2 rounded-lg hover:bg-raised group transition-colors"
            >
              <div className="flex items-start gap-2">
                <span className="text-dim text-xs mt-0.5 shrink-0">
                  {entry.mode === 'chat' ? '◈' : entry.mode === 'code' ? '⟨⟩' : '⬡'}
                </span>
                <div className="min-w-0">
                  <p className="text-xs text-slate-300 group-hover:text-slate-100 truncate leading-snug">{entry.title}</p>
                  <p className="text-xs text-dim">{entry.updatedAt}</p>
                </div>
              </div>
            </button>
          ))}
        </div>
      </div>
    </aside>
  )
}

// ◼︎ DOJO Web — main page
// Three-mode interface: Chat | Code | Collaborate
// Left: sidebar (history + chambers) | Centre: active mode | Right: MCP panel (toggleable)

'use client'

import { useState } from 'react'
import { ChatInterface } from '@/components/field/ChatInterface'
import { CodeArtifact } from '@/components/field/CodeArtifact'
import { CollabPanel } from '@/components/field/CollabPanel'
import { ChamberSidebar } from '@/components/field/ChamberSidebar'
import { MCPPanel } from '@/components/field/MCPPanel'
import { SpellCircle } from '@/components/field/SpellCircle'

type Mode = 'chat' | 'code' | 'collab'

export default function DOJOPage() {
  const [mode, setMode] = useState<Mode>('chat')
  const [mcpOpen, setMcpOpen] = useState(false)
  const [conversationId] = useState(() => crypto.randomUUID())

  return (
    <div className="flex h-screen overflow-hidden bg-void text-slate-100">

      {/* ── Left sidebar ──────────────────────────────────────────── */}
      <ChamberSidebar />

      {/* ── Main area ─────────────────────────────────────────────── */}
      <div className="flex flex-col flex-1 min-w-0">

        {/* Top bar */}
        <header className="flex items-center justify-between px-4 py-3 border-b border-border bg-surface shrink-0">
          {/* DOJO identity */}
          <div className="flex items-center gap-3">
            <SpellCircle chamber="dojo" size={32} compact />
            <div>
              <span className="font-mono text-sm font-semibold text-dojo">◼︎ DOJO</span>
              <span className="ml-2 font-mono text-xs text-muted">741 Hz — Manifestation apex</span>
            </div>
          </div>

          {/* Mode tabs */}
          <nav className="flex gap-1 bg-raised rounded-lg p-1">
            {(['chat', 'code', 'collab'] as Mode[]).map(m => (
              <button
                key={m}
                onClick={() => setMode(m)}
                className={`px-4 py-1.5 rounded-md text-sm font-medium transition-all ${
                  mode === m
                    ? 'bg-dojo/20 text-dojo shadow-sm'
                    : 'text-muted hover:text-slate-300'
                }`}
              >
                {m === 'chat'  ? '◈ Chat'
                : m === 'code' ? '⟨/⟩ Code'
                :                '⬡ Collaborate'}
              </button>
            ))}
          </nav>

          {/* MCP toggle */}
          <button
            onClick={() => setMcpOpen(o => !o)}
            className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm font-mono transition-all border ${
              mcpOpen
                ? 'border-arkadas/40 bg-arkadas/10 text-arkadas'
                : 'border-border text-muted hover:text-slate-300 hover:border-slate-600'
            }`}
          >
            <span>⬡</span>
            <span>MCP</span>
          </button>
        </header>

        {/* Mode content */}
        <main className="flex-1 overflow-hidden">
          {mode === 'chat'  && <ChatInterface conversationId={conversationId} />}
          {mode === 'code'  && <CodeArtifact />}
          {mode === 'collab'&& <CollabPanel />}
        </main>
      </div>

      {/* ── Right MCP panel (slide-in) ─────────────────────────────── */}
      {mcpOpen && <MCPPanel onClose={() => setMcpOpen(false)} />}
    </div>
  )
}

'use client'

// ◼ Foreman — unified comms command surface
// Each mode is a different paper. TG is the organising principle.
// You are not reading an inbox — you are holding correspondence.

import { useEffect, useRef, useState } from 'react'

type ChannelMode = 'personal' | 'business' | 'legal' | 'regulatory'
type CommChannel = 'whatsapp' | 'imessage' | 'signal' | 'messenger' | 'email' | 'matrix'

interface ChannelDef {
  symbol: string
  label: string
  colour: string
  bg: string
  mode: ChannelMode
  from: string
}

const CHANNELS: Record<ChannelMode, ChannelDef> = {
  personal:   { symbol: '●', label: 'Personal',    colour: '#5b8db8', bg: 'rgba(91,141,184,0.05)',   mode: 'personal',   from: 'jeremy.rich@berjak.com.au' },
  business:   { symbol: '▲', label: 'Business',    colour: '#5a8a5a', bg: 'rgba(90,138,90,0.05)',    mode: 'business',   from: 'info@berjak.com.au' },
  legal:      { symbol: '▼', label: 'Legal / POA', colour: '#9b5050', bg: 'rgba(155,80,80,0.06)',    mode: 'legal',      from: 'accounts@berjak.com.au' },
  regulatory: { symbol: '◼', label: 'Regulatory',  colour: '#7b6b8b', bg: 'rgba(123,107,139,0.06)', mode: 'regulatory', from: 'operations@berjak.com.au' },
}

// ── Message model ────────────────────────────────────────────────────────────

export interface CommMessage {
  id: string
  channel: CommChannel
  mode: ChannelMode
  from: string
  fromHandle?: string
  body: string
  attachments?: Array<{ type: 'image' | 'document' | 'audio'; name: string; url?: string }>
  receivedAt: string
  tg: number          // Temporal Gravity [0–1]
  tgFactors?: {
    recurrence: number
    coherence: number
    embodiment: number
    duration: number
  }
  threadId?: string
  caseRef?: string
  draft?: string
  status: 'unread' | 'drafting' | 'sent' | 'dismissed'
}

// ── TG computation (heuristic for manual operation) ──────────────────────────

const LEGAL_KEYWORDS = /swiss|foreclosure|poursuite|finma|bekb|ira|asic|complaint|estate|probate|court|legal|urgent|consent|fraud/i
const COMMERCIAL_PATTERNS = /unsubscribe|no.reply|newsletter|marketing|promotion|offer|sale|deal|special/i

function computeTG(msg: Omit<CommMessage, 'tg' | 'tgFactors'>): { tg: number; tgFactors: CommMessage['tgFactors'] } {
  if (COMMERCIAL_PATTERNS.test(msg.body) || COMMERCIAL_PATTERNS.test(msg.from)) {
    return { tg: 0.05, tgFactors: { recurrence: 0, coherence: 0, embodiment: 0, duration: 0 } }
  }

  const recurrence  = msg.threadId ? 0.8 : 0.4
  const coherence   = msg.caseRef  ? 0.9 : LEGAL_KEYWORDS.test(msg.body) ? 0.75 : 0.45
  const embodiment  = msg.mode === 'regulatory' || msg.mode === 'legal' ? 0.85 : 0.5
  const duration    = (msg.mode === 'regulatory' || msg.mode === 'legal') ? 0.9 : 0.4

  const tg = (recurrence * 0.25) + (coherence * 0.35) + (embodiment * 0.2) + (duration * 0.2)
  return { tg, tgFactors: { recurrence, coherence, embodiment, duration } }
}

// ── TG bar component ─────────────────────────────────────────────────────────

function TGBar({ score, colour }: { score: number; colour: string }) {
  const pct = Math.round(score * 100)
  const barColour =
    score >= 0.8 ? '#c0534a' :   // high — urgent red
    score >= 0.5 ? '#c8844a' :   // medium — amber
    score >= 0.2 ? '#8a8a6a' :   // low — slate
                   '#3a3a3a'     // noise — near invisible

  return (
    <div className="flex items-center gap-2">
      <div className="relative w-16 h-1 bg-raised rounded-full overflow-hidden">
        <div
          className="absolute left-0 top-0 h-full rounded-full transition-all"
          style={{ width: `${pct}%`, backgroundColor: barColour }}
        />
      </div>
      <span className="font-mono text-[10px]" style={{ color: barColour }}>
        TG {pct}
      </span>
    </div>
  )
}

// ── Channel badge ────────────────────────────────────────────────────────────

function ChannelBadge({ mode, channel, active }: { mode: ChannelMode; channel: CommChannel; active: boolean }) {
  const def = CHANNELS[mode]
  const ICONS: Record<CommChannel, string> = {
    whatsapp: 'WA', imessage: 'iM', signal: 'SG', messenger: 'MS', email: 'EM', matrix: 'MX',
  }
  return (
    <div className="flex items-center gap-1.5">
      <span
        className="text-base leading-none transition-opacity"
        style={{ color: active ? def.colour : '#555', opacity: active ? 1 : 0.4 }}
      >
        {def.symbol}
      </span>
      <span className="font-mono text-[10px] text-muted">{ICONS[channel]}</span>
    </div>
  )
}

// ── Message card ─────────────────────────────────────────────────────────────

interface CardProps {
  msg: CommMessage
  selected: boolean
  onSelect: () => void
}

function MessageCard({ msg, selected, onSelect }: CardProps) {
  const def = CHANNELS[msg.mode]
  const isNoise = msg.tg < 0.15
  if (isNoise && !selected) {
    return (
      <button
        onClick={onSelect}
        className="w-full text-left px-4 py-2 border-b border-border/30 opacity-30 hover:opacity-50 transition-opacity"
      >
        <div className="flex items-center gap-2">
          <span className="text-[10px] font-mono text-muted">{def.symbol}</span>
          <span className="text-xs text-muted truncate">{msg.from} — {msg.body.slice(0, 40)}…</span>
        </div>
      </button>
    )
  }

  return (
    <button
      onClick={onSelect}
      className={`w-full text-left px-4 py-3 border-b border-border transition-all ${
        selected
          ? 'bg-surface/80'
          : 'bg-void hover:bg-surface/30'
      }`}
    >
      <div className="flex items-start gap-3">
        <ChannelBadge mode={msg.mode} channel={msg.channel} active={msg.tg >= 0.5} />
        <div className="flex-1 min-w-0">
          <div className="flex items-center justify-between mb-0.5">
            <span
              className="text-sm font-medium truncate"
              style={{ color: msg.tg >= 0.5 ? def.colour : '#94a3b8' }}
            >
              {msg.from}
            </span>
            <span className="text-[10px] font-mono text-muted ml-2 shrink-0">
              {formatTime(msg.receivedAt)}
            </span>
          </div>
          <p className="text-xs text-muted truncate">{msg.body}</p>
          <div className="mt-1.5">
            <TGBar score={msg.tg} colour={def.colour} />
          </div>
        </div>
        {msg.status === 'sent' && (
          <span className="text-[10px] font-mono text-slate-500 shrink-0">sent</span>
        )}
        {msg.caseRef && (
          <span className="text-[10px] font-mono text-muted shrink-0 hidden sm:block">{msg.caseRef}</span>
        )}
      </div>
      {msg.attachments && msg.attachments.length > 0 && (
        <div className="flex gap-1.5 mt-1.5 ml-8">
          {msg.attachments.map((att, i) => (
            <span key={i} className="text-[10px] font-mono text-muted border border-border/50 rounded px-1.5 py-0.5">
              {att.type === 'image' ? '◎' : att.type === 'document' ? '⬢' : '◯'} {att.name}
            </span>
          ))}
        </div>
      )}
    </button>
  )
}

// ── Draft panel ──────────────────────────────────────────────────────────────

interface DraftProps {
  msg: CommMessage
  onSend: (text: string) => void
  onDismiss: () => void
}

function DraftPanel({ msg, onSend, onDismiss }: DraftProps) {
  const def = CHANNELS[msg.mode]
  const [draft, setDraft] = useState(msg.draft ?? '')
  const textRef = useRef<HTMLTextAreaElement>(null)

  useEffect(() => {
    setDraft(msg.draft ?? '')
    textRef.current?.focus()
  }, [msg.id, msg.draft])

  // Subject line convention: symbol opens the subject
  const subjectPrefix = def.symbol

  return (
    <div className="flex flex-col h-full bg-surface/50 border-l border-border">
      {/* Header */}
      <div className="px-5 py-4 border-b border-border shrink-0">
        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0">
            {/* ● ▼ ▲ ◼ mark — same as stationery */}
            <div className="flex items-center gap-2 mb-1">
              {Object.values(CHANNELS).map(ch => (
                <span
                  key={ch.symbol}
                  className="text-base leading-none transition-all"
                  style={{
                    color: ch.mode === msg.mode ? ch.colour : '#444',
                    opacity: ch.mode === msg.mode ? 1 : 0.3,
                  }}
                >
                  {ch.symbol}
                </span>
              ))}
            </div>
            <p className="text-xs text-muted font-mono truncate">
              {subjectPrefix} {msg.from}
              {msg.fromHandle && <span className="opacity-50"> · {msg.fromHandle}</span>}
            </p>
            {msg.caseRef && (
              <p className="text-[10px] font-mono mt-0.5" style={{ color: def.colour }}>
                {msg.caseRef}
              </p>
            )}
          </div>
          <TGBar score={msg.tg} colour={def.colour} />
        </div>
      </div>

      {/* Incoming */}
      <div className="px-5 py-4 border-b border-border shrink-0">
        <p className="text-xs text-muted font-mono uppercase tracking-wider mb-2">Received</p>
        <p className="text-sm text-slate-300 whitespace-pre-wrap leading-relaxed">{msg.body}</p>
        {msg.attachments && msg.attachments.length > 0 && (
          <div className="flex gap-1.5 mt-3">
            {msg.attachments.map((att, i) => (
              <div key={i} className="text-[11px] font-mono text-muted border border-border/50 rounded px-2 py-1">
                {att.type === 'image' ? '◎ img' : att.type === 'document' ? '⬢ doc' : '◯ audio'} {att.name}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Draft */}
      <div className="flex flex-col flex-1 px-5 py-4 min-h-0">
        <div className="flex items-center justify-between mb-2">
          <p className="text-xs text-muted font-mono uppercase tracking-wider">Draft</p>
          <span className="text-[10px] font-mono" style={{ color: def.colour }}>
            {def.symbol} {def.label} mode
          </span>
        </div>
        <textarea
          ref={textRef}
          value={draft}
          onChange={e => setDraft(e.target.value)}
          placeholder="Write response…"
          className="flex-1 resize-none bg-raised border border-border rounded-lg px-3 py-2.5 text-sm text-slate-200 placeholder:text-muted focus:outline-none focus:border-slate-500 font-sans leading-relaxed min-h-[80px]"
        />
      </div>

      {/* Controls */}
      <div className="px-5 py-4 border-t border-border shrink-0">
        <div className="flex items-center justify-between">
          <button
            onClick={onDismiss}
            className="text-sm text-muted hover:text-slate-300 transition-colors font-mono"
          >
            dismiss
          </button>
          <div className="flex gap-2">
            <button
              onClick={() => setDraft('')}
              className="px-3 py-1.5 text-sm font-mono text-muted hover:text-slate-300 border border-border rounded-md transition-colors"
            >
              clear
            </button>
            <button
              onClick={() => { if (draft.trim()) onSend(draft.trim()) }}
              disabled={!draft.trim()}
              className="px-4 py-1.5 text-sm font-mono rounded-md transition-all disabled:opacity-30 disabled:cursor-not-allowed"
              style={{
                backgroundColor: draft.trim() ? def.colour : undefined,
                color: draft.trim() ? '#fff' : undefined,
                border: `1px solid ${def.colour}`,
              }}
            >
              {def.symbol} send
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

// ── Filters ──────────────────────────────────────────────────────────────────

type FilterMode = 'all' | ChannelMode | 'high'

const FILTER_LABELS: Array<{ id: FilterMode; label: string }> = [
  { id: 'all',        label: 'All'          },
  { id: 'high',       label: '◎ High TG'    },
  { id: 'regulatory', label: '◼ Regulatory' },
  { id: 'legal',      label: '▼ Legal'      },
  { id: 'business',   label: '▲ Business'   },
  { id: 'personal',   label: '● Personal'   },
]

// ── Main panel ───────────────────────────────────────────────────────────────

interface Props {
  matrixConnected?: boolean
}

export function ForemanPanel({ matrixConnected = false }: Props) {
  const [messages, setMessages] = useState<CommMessage[]>([])
  const [selected, setSelected] = useState<string | null>(null)
  const [filter, setFilter] = useState<FilterMode>('all')
  const [loading, setLoading] = useState(true)

  // Load comms from API (stub → Matrix when Gemini synopsis is wired)
  useEffect(() => {
    let cancelled = false

    async function loadComms() {
      setLoading(true)
      try {
        const res = await fetch('/api/comms', { cache: 'no-store' })
        if (!res.ok) throw new Error(`HTTP ${res.status}`)
        const raw: Omit<CommMessage, 'tg' | 'tgFactors'>[] = await res.json()
        if (cancelled) return
        const scored = raw.map(msg => ({ ...msg, ...computeTG(msg) }))
        scored.sort((a, b) => b.tg - a.tg)
        setMessages(scored)
        if (scored.length > 0 && !selected) setSelected(scored[0].id)
      } catch {
        // Populate with empty state — real data arrives via Matrix bridge
        if (!cancelled) setMessages([])
      } finally {
        if (!cancelled) setLoading(false)
      }
    }

    loadComms()
    const interval = window.setInterval(loadComms, 30_000)
    return () => {
      cancelled = true
      window.clearInterval(interval)
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  function handleSend(msgId: string, text: string) {
    setMessages(prev => prev.map(m =>
      m.id === msgId ? { ...m, status: 'sent', draft: text } : m
    ))
    // POST to comms API — bridges will route to correct channel
    fetch('/api/comms/send', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ messageId: msgId, text }),
    }).catch(() => {/* will retry — sovereign, never fire-and-forget silently */})
  }

  function handleDismiss(msgId: string) {
    setMessages(prev => prev.map(m =>
      m.id === msgId ? { ...m, status: 'dismissed' } : m
    ))
    const remaining = messages.filter(m => m.id !== msgId && m.status !== 'dismissed')
    setSelected(remaining[0]?.id ?? null)
  }

  const filtered = messages.filter(m => {
    if (m.status === 'dismissed') return false
    if (filter === 'all')  return true
    if (filter === 'high') return m.tg >= 0.65
    return m.mode === filter
  })

  const selectedMsg = filtered.find(m => m.id === selected) ?? filtered[0] ?? null
  const unreadCount = messages.filter(m => m.status === 'unread').length

  return (
    <div className="flex h-full overflow-hidden">

      {/* ── Left: ranked inbox ─────────────────────────────────────────── */}
      <div className="w-80 flex flex-col border-r border-border shrink-0">

        {/* Header */}
        <div className="px-4 py-3 border-b border-border shrink-0">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="font-mono text-sm font-semibold text-slate-200">⊗ Foreman</span>
              {unreadCount > 0 && (
                <span className="text-[10px] font-mono bg-dojo/20 text-dojo px-1.5 py-0.5 rounded">
                  {unreadCount}
                </span>
              )}
            </div>
            <div className="flex items-center gap-1.5">
              <span
                className="w-1.5 h-1.5 rounded-full"
                style={{ backgroundColor: matrixConnected ? '#5a7a5a' : '#555' }}
                title={matrixConnected ? 'Matrix connected' : 'Matrix offline'}
              />
              <span className="text-[10px] font-mono text-muted">
                {matrixConnected ? 'live' : 'offline'}
              </span>
            </div>
          </div>

          {/* Channel identity mark — stationery spec */}
          <div className="flex items-center gap-3 mt-2">
            {Object.values(CHANNELS).map(ch => (
              <span key={ch.symbol} className="text-xs leading-none" style={{ color: ch.colour, opacity: 0.7 }}>
                {ch.symbol}
              </span>
            ))}
            <span className="font-mono text-[10px] text-muted">● JB Rich</span>
          </div>
        </div>

        {/* Filters */}
        <div className="flex gap-1 px-3 py-2 border-b border-border overflow-x-auto shrink-0">
          {FILTER_LABELS.map(f => (
            <button
              key={f.id}
              onClick={() => setFilter(f.id)}
              className={`px-2.5 py-1 rounded text-[11px] font-mono whitespace-nowrap transition-all ${
                filter === f.id
                  ? 'bg-slate-700 text-slate-200'
                  : 'text-muted hover:text-slate-300'
              }`}
            >
              {f.label}
            </button>
          ))}
        </div>

        {/* Message list — ranked by TG */}
        <div className="flex-1 overflow-y-auto">
          {loading ? (
            <div className="px-4 py-8 text-center">
              <p className="text-xs font-mono text-muted">Reading bridges…</p>
            </div>
          ) : filtered.length === 0 ? (
            <div className="px-4 py-8 text-center">
              <div className="flex justify-center gap-3 mb-3 opacity-20">
                {Object.values(CHANNELS).map(ch => (
                  <span key={ch.symbol} style={{ color: ch.colour }}>{ch.symbol}</span>
                ))}
              </div>
              <p className="text-xs font-mono text-muted">
                {matrixConnected ? 'No messages' : 'Connect Matrix bridges to receive messages'}
              </p>
            </div>
          ) : (
            filtered.map(msg => (
              <MessageCard
                key={msg.id}
                msg={msg}
                selected={msg.id === selectedMsg?.id}
                onSelect={() => setSelected(msg.id)}
              />
            ))
          )}
        </div>

        {/* Bridge status footer */}
        <div className="px-4 py-2 border-t border-border shrink-0">
          <p className="text-[10px] font-mono text-muted">
            Bridges: WA ✓ — SG ✗ — iM — — — EM —
          </p>
        </div>
      </div>

      {/* ── Right: draft panel ─────────────────────────────────────────── */}
      <div className="flex-1 min-w-0">
        {selectedMsg ? (
          <DraftPanel
            msg={selectedMsg}
            onSend={text => handleSend(selectedMsg.id, text)}
            onDismiss={() => handleDismiss(selectedMsg.id)}
          />
        ) : (
          <div className="flex flex-col h-full items-center justify-center">
            <div className="flex gap-4 mb-4 opacity-10">
              {Object.values(CHANNELS).map(ch => (
                <span key={ch.symbol} className="text-2xl" style={{ color: ch.colour }}>
                  {ch.symbol}
                </span>
              ))}
            </div>
            <p className="text-sm font-mono text-muted">Select a message</p>
            <p className="text-xs font-mono text-muted/50 mt-1">
              Messages ranked by Temporal Gravity
            </p>
          </div>
        )}
      </div>
    </div>
  )
}

// ── Helpers ──────────────────────────────────────────────────────────────────

function formatTime(iso: string): string {
  const d = new Date(iso)
  const now = new Date()
  const diffMs = now.getTime() - d.getTime()
  const diffH = diffMs / 3_600_000
  if (diffH < 1)   return `${Math.round(diffMs / 60_000)}m`
  if (diffH < 24)  return `${Math.round(diffH)}h`
  return `${Math.round(diffH / 24)}d`
}

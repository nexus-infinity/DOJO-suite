'use client'

import { useState, useRef, useEffect } from 'react'
import { SpellCircle } from './SpellCircle'

interface Message {
  id: string
  role: 'user' | 'assistant' | 'tool'
  content: string
  toolName?: string
  timestamp: Date
}

interface Props { conversationId: string }

export function ChatInterface({ conversationId }: Props) {
  const [messages, setMessages] = useState<Message[]>([])
  const [input, setInput] = useState('')
  const [streaming, setStreaming] = useState(false)
  const bottomRef = useRef<HTMLDivElement>(null)
  const textareaRef = useRef<HTMLTextAreaElement>(null)

  useEffect(() => { bottomRef.current?.scrollIntoView({ behavior: 'smooth' }) }, [messages])

  async function send() {
    const text = input.trim()
    if (!text || streaming) return
    setInput('')

    const userMsg: Message = { id: crypto.randomUUID(), role: 'user', content: text, timestamp: new Date() }
    setMessages(prev => [...prev, userMsg])
    setStreaming(true)

    const assistantId = crypto.randomUUID()
    setMessages(prev => [...prev, { id: assistantId, role: 'assistant', content: '', timestamp: new Date() }])

    try {
      const res = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: text,
          conversationId,
          history: messages.map(m => ({ role: m.role, content: m.content })),
        }),
      })

      if (!res.body) throw new Error('No response body')

      const reader = res.body.getReader()
      const decoder = new TextDecoder()
      let accumulated = ''

      while (true) {
        const { done, value } = await reader.read()
        if (done) break
        const chunk = decoder.decode(value, { stream: true })
        // Parse SSE lines
        for (const line of chunk.split('\n')) {
          if (line.startsWith('data: ')) {
            try {
              const data = JSON.parse(line.slice(6))
              if (data.content) {
                accumulated += data.content
                setMessages(prev => prev.map(m =>
                  m.id === assistantId ? { ...m, content: accumulated } : m
                ))
              }
            } catch {}
          }
        }
      }
    } catch (err) {
      setMessages(prev => prev.map(m =>
        m.id === assistantId
          ? { ...m, content: `◼︎ DOJO unreachable — check Mac Studio is running on :7410\n\n${err}` }
          : m
      ))
    } finally {
      setStreaming(false)
    }
  }

  function onKeyDown(e: React.KeyboardEvent) {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); send() }
  }

  return (
    <div className="flex flex-col h-full">

      {/* Messages */}
      <div className="flex-1 overflow-y-auto px-4 py-6 space-y-6">
        {messages.length === 0 && <EmptyState />}

        {messages.map(msg => (
          <div key={msg.id} className={`flex gap-3 ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}>
            {msg.role === 'assistant' && (
              <div className="shrink-0 mt-1">
                <SpellCircle chamber="dojo" size={28} compact />
              </div>
            )}

            {msg.role === 'tool' && (
              <div className="shrink-0 mt-1 w-7 h-7 rounded-full bg-arkadas/20 flex items-center justify-center text-xs text-arkadas">⬡</div>
            )}

            <div className={`max-w-[72%] rounded-2xl px-4 py-3 ${
              msg.role === 'user'
                ? 'bg-dojo/20 text-slate-100 rounded-tr-sm'
                : msg.role === 'tool'
                ? 'bg-arkadas/10 border border-arkadas/20 text-sm font-mono text-slate-300'
                : 'bg-surface text-slate-100 rounded-tl-sm'
            }`}>
              {msg.role === 'tool' && (
                <div className="text-xs text-arkadas mb-1 font-semibold">⬡ {msg.toolName}</div>
              )}
              <MessageContent content={msg.content} streaming={streaming && msg.role === 'assistant' && !msg.content} />
            </div>

            {msg.role === 'user' && (
              <div className="shrink-0 mt-1 w-7 h-7 rounded-full bg-obiwan/10 border border-obiwan/20 flex items-center justify-center text-xs">●</div>
            )}
          </div>
        ))}
        <div ref={bottomRef} />
      </div>

      {/* Input */}
      <div className="px-4 pb-4 shrink-0">
        <div className="flex gap-3 items-end bg-surface border border-border rounded-2xl px-4 py-3 focus-within:border-dojo/40 transition-colors">
          <textarea
            ref={textareaRef}
            value={input}
            onChange={e => setInput(e.target.value)}
            onKeyDown={onKeyDown}
            placeholder="Message NIAMA…"
            rows={1}
            className="flex-1 bg-transparent resize-none outline-none text-slate-100 placeholder:text-muted text-sm leading-relaxed max-h-40 overflow-y-auto"
            style={{ fontFamily: 'inherit' }}
          />
          <button
            onClick={send}
            disabled={!input.trim() || streaming}
            className="shrink-0 w-8 h-8 rounded-xl bg-dojo/80 hover:bg-dojo disabled:opacity-30 disabled:cursor-not-allowed flex items-center justify-center transition-all"
          >
            {streaming
              ? <span className="w-3 h-3 rounded-sm bg-white/60 animate-pulse" />
              : <span className="text-white text-sm">↑</span>
            }
          </button>
        </div>
        <p className="text-center text-xs text-dim mt-2 font-mono">◼︎ DOJO  741 Hz — connected to Mac Studio :7410</p>
      </div>
    </div>
  )
}

function EmptyState() {
  return (
    <div className="flex flex-col items-center justify-center h-full py-20 gap-6 portal-in">
      <SpellCircle chamber="dojo" size={96} />
      <div className="text-center">
        <h1 className="text-2xl font-semibold text-slate-100 mb-1">NIAMA</h1>
        <p className="text-muted text-sm font-mono">◼︎ DOJO  741 Hz — Manifestation apex</p>
        <p className="text-dim text-xs mt-3 max-w-xs">Evidence-first. Cat-speed execution.<br />What needs manifesting?</p>
      </div>
    </div>
  )
}

function MessageContent({ content, streaming }: { content: string; streaming: boolean }) {
  if (!content && streaming) {
    return (
      <span className="flex gap-1 items-center h-5">
        {[0,1,2].map(i => (
          <span key={i} className="w-1.5 h-1.5 rounded-full bg-dojo/60 animate-pulse" style={{ animationDelay: `${i * 150}ms` }} />
        ))}
      </span>
    )
  }

  // Detect and render code blocks
  const parts = content.split(/(```[\s\S]*?```)/g)
  return (
    <div className="prose prose-invert prose-sm max-w-none">
      {parts.map((part, i) => {
        if (part.startsWith('```')) {
          const match = part.match(/^```(\w*)\n?([\s\S]*?)```$/)
          const lang = match?.[1] || ''
          const code = match?.[2] || part.slice(3, -3)
          return (
            <pre key={i} className="bg-raised border border-border rounded-lg p-3 overflow-x-auto text-xs font-mono text-slate-200 my-2">
              {lang && <div className="text-dim text-xs mb-2 font-mono">{lang}</div>}
              <code>{code}</code>
            </pre>
          )
        }
        return <span key={i} className="whitespace-pre-wrap text-sm leading-relaxed">{part}</span>
      })}
    </div>
  )
}

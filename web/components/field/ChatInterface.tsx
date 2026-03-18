'use client'

import { useEffect, useMemo, useRef, useState } from 'react'
import { SpellCircle } from './SpellCircle'
import { type SessionMessage, type WorkstreamSuggestion } from '@/lib/sessionStore'

interface Props {
  conversationId: string
  messages: SessionMessage[]
  includeArchive: boolean
  suggestions: WorkstreamSuggestion[]
  onMessagesChange: (messages: SessionMessage[]) => void
  chamberConnected: boolean
  onToggleIncludeArchive: (value: boolean) => void
  onAttachWorkstream: (workstreamId: string) => Promise<void> | void
  onKeepSeparate: () => Promise<void> | void
}

interface Message extends Omit<SessionMessage, 'timestamp'> {
  timestamp: Date
}

export function ChatInterface({
  conversationId,
  messages: persistedMessages,
  includeArchive,
  suggestions,
  onMessagesChange,
  chamberConnected,
  onToggleIncludeArchive,
  onAttachWorkstream,
  onKeepSeparate,
}: Props) {
  const [messages, setMessages] = useState<Message[]>(() => hydrateMessages(persistedMessages))
  const [input, setInput] = useState('')
  const [streaming, setStreaming] = useState(false)
  const [handlingSuggestion, setHandlingSuggestion] = useState(false)
  const bottomRef = useRef<HTMLDivElement>(null)
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  const persistedSignature = useMemo(() => JSON.stringify(persistedMessages), [persistedMessages])
  const lastPublishedSignature = useRef(persistedSignature)
  const onMessagesChangeRef = useRef(onMessagesChange)

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages])

  useEffect(() => {
    onMessagesChangeRef.current = onMessagesChange
  }, [onMessagesChange])

  useEffect(() => {
    const next = JSON.stringify(serializeMessages(messages))
    if (next === lastPublishedSignature.current) return
    lastPublishedSignature.current = next
    onMessagesChangeRef.current(JSON.parse(next) as SessionMessage[])
  }, [messages])

  async function send() {
    const text = input.trim()
    if (!text || streaming) return
    setInput('')

    const userMsg: Message = { id: crypto.randomUUID(), role: 'user', content: text, timestamp: new Date() }
    const assistantId = crypto.randomUUID()
    const nextMessages = [...messages, userMsg]

    setMessages([...nextMessages, { id: assistantId, role: 'assistant', content: '', timestamp: new Date() }])
    setStreaming(true)

    try {
      const res = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: text,
          conversationId,
          includeArchive,
          history: nextMessages.map(message => ({ role: message.role, content: message.content })),
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
        for (const line of chunk.split('\n')) {
          if (!line.startsWith('data: ')) continue
          try {
            const data = JSON.parse(line.slice(6))
            if (data.content) {
              accumulated += data.content
              setMessages(prev => prev.map(message =>
                message.id === assistantId ? { ...message, content: accumulated } : message
              ))
            }
          } catch {
            continue
          }
        }
      }
    } catch (error) {
      setMessages(prev => prev.map(message =>
        message.id === assistantId
          ? { ...message, content: `◼︎ DOJO unreachable — check Mac Studio is running on :7410\n\n${String(error)}` }
          : message
      ))
    } finally {
      setStreaming(false)
      textareaRef.current?.focus()
    }
  }

  async function handleAttach(workstreamId: string) {
    setHandlingSuggestion(true)
    try {
      await onAttachWorkstream(workstreamId)
    } finally {
      setHandlingSuggestion(false)
    }
  }

  async function handleSeparate() {
    setHandlingSuggestion(true)
    try {
      await onKeepSeparate()
    } finally {
      setHandlingSuggestion(false)
    }
  }

  function onKeyDown(event: React.KeyboardEvent) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault()
      send()
    }
  }

  const topSuggestion = suggestions[0] ?? null

  return (
    <div className="flex h-full flex-col">
      <div className="border-b border-border bg-surface/70 px-4 py-3">
        <div className="flex flex-col gap-3 xl:flex-row xl:items-start xl:justify-between">
          <div className="space-y-2">
            <div className="flex items-center gap-2">
              <span className="rounded-full border border-border px-2 py-0.5 text-[11px] font-mono uppercase tracking-wider text-muted">
                Retrieval
              </span>
              <span className="text-xs text-dim">
                Session → workstreams → confirmed memory → draft memory
              </span>
            </div>

            {topSuggestion && (
              <div className="rounded-2xl border border-dojo/20 bg-dojo/8 px-3 py-3">
                <div className="flex flex-col gap-2 lg:flex-row lg:items-center lg:justify-between">
                  <div>
                    <p className="text-sm font-medium text-slate-100">
                      {topSuggestion.isAmbiguous ? 'Potential workstream overlap detected' : 'Continue in existing workstream'}
                    </p>
                    <p className="text-xs text-muted">
                      `{topSuggestion.workstreamId}` • {topSuggestion.reason}
                    </p>
                    {topSuggestion.isAmbiguous && (
                      <p className="mt-1 text-xs text-amber-300">
                        Multiple clusters are close. Continue only if this thread should inherit that field context.
                      </p>
                    )}
                  </div>
                  <div className="flex gap-2">
                    <button
                      onClick={() => handleAttach(topSuggestion.workstreamId)}
                      disabled={handlingSuggestion}
                      className="rounded-lg border border-dojo/30 bg-dojo/20 px-3 py-1.5 text-sm text-dojo transition-colors hover:bg-dojo/30 disabled:opacity-50"
                    >
                      Continue there
                    </button>
                    <button
                      onClick={handleSeparate}
                      disabled={handlingSuggestion}
                      className="rounded-lg border border-border px-3 py-1.5 text-sm text-muted transition-colors hover:text-slate-200 disabled:opacity-50"
                    >
                      Keep separate
                    </button>
                  </div>
                </div>
              </div>
            )}
          </div>

          <label className="flex items-center gap-3 rounded-2xl border border-border px-3 py-2 text-sm text-slate-200">
            <input
              type="checkbox"
              checked={includeArchive}
              onChange={event => onToggleIncludeArchive(event.target.checked)}
              className="h-4 w-4 rounded border-border bg-transparent accent-dojo"
            />
            <div>
              <p className="font-medium">Include archive for this chat</p>
              <p className="text-xs text-dim">Temporary recall expansion. Archived sessions remain outside the active grey zone.</p>
            </div>
          </label>
        </div>
      </div>

      <div className="flex-1 space-y-6 overflow-y-auto px-4 py-6">
        {messages.length === 0 && <EmptyState />}

        {messages.map(message => (
          <div key={message.id} className={`flex gap-3 ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}>
            {message.role === 'assistant' && (
              <div className="mt-1 shrink-0">
                <SpellCircle chamber="dojo" size={28} compact />
              </div>
            )}

            {message.role === 'tool' && (
              <div className="mt-1 flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-arkadas/20 text-xs text-arkadas">
                ⬡
              </div>
            )}

            <div
              className={`max-w-[78%] rounded-2xl px-4 py-3 ${
                message.role === 'user'
                  ? 'rounded-tr-sm bg-dojo/20 text-slate-100'
                  : message.role === 'tool'
                    ? 'border border-arkadas/20 bg-arkadas/10 font-mono text-sm text-slate-300'
                    : 'rounded-tl-sm bg-surface text-slate-100'
              }`}
            >
              {message.role === 'tool' && (
                <div className="mb-1 text-xs font-semibold text-arkadas">⬡ {message.toolName}</div>
              )}
              <MessageContent content={message.content} streaming={streaming && message.role === 'assistant' && !message.content} />
            </div>

            {message.role === 'user' && (
              <div className="mt-1 flex h-7 w-7 shrink-0 items-center justify-center rounded-full border border-obiwan/20 bg-obiwan/10 text-xs">
                ●
              </div>
            )}
          </div>
        ))}
        <div ref={bottomRef} />
      </div>

      <div className="shrink-0 px-4 pb-4">
        <div className="flex items-end gap-3 rounded-2xl border border-border bg-surface px-4 py-3 transition-colors focus-within:border-dojo/40">
          <textarea
            ref={textareaRef}
            value={input}
            onChange={event => setInput(event.target.value)}
            onKeyDown={onKeyDown}
            placeholder="Message NIAMA…"
            rows={1}
            className="max-h-40 flex-1 resize-none overflow-y-auto bg-transparent text-sm leading-relaxed text-slate-100 outline-none placeholder:text-muted"
            style={{ fontFamily: 'inherit' }}
          />
          <button
            onClick={send}
            disabled={!input.trim() || streaming}
            className="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-dojo/80 transition-all hover:bg-dojo disabled:cursor-not-allowed disabled:opacity-30"
          >
            {streaming
              ? <span className="h-3 w-3 animate-pulse rounded-sm bg-white/60" />
              : <span className="text-sm text-white">↑</span>}
          </button>
        </div>
        <p className="mt-2 text-center font-mono text-xs text-dim">
          {chamberConnected
            ? '◼︎ DOJO  741 Hz — live route to Mac Studio :7410'
            : '◼︎ DOJO  741 Hz — solo mode, Mac Studio route currently offline'}
        </p>
      </div>
    </div>
  )
}

function EmptyState() {
  return (
    <div className="portal-in flex h-full flex-col items-center justify-center gap-6 py-20">
      <SpellCircle chamber="dojo" size={96} />
      <div className="text-center">
        <h1 className="mb-1 text-2xl font-semibold text-slate-100">NIAMA</h1>
        <p className="font-mono text-sm text-muted">◼︎ DOJO  741 Hz — Manifestation apex</p>
        <p className="mt-3 max-w-xs text-xs text-dim">Evidence-first. Cat-speed execution.<br />What needs manifesting?</p>
      </div>
    </div>
  )
}

function MessageContent({ content, streaming }: { content: string; streaming: boolean }) {
  if (!content && streaming) {
    return (
      <span className="flex h-5 items-center gap-1">
        {[0, 1, 2].map(index => (
          <span
            key={index}
            className="h-1.5 w-1.5 animate-pulse rounded-full bg-dojo/60"
            style={{ animationDelay: `${index * 150}ms` }}
          />
        ))}
      </span>
    )
  }

  const parts = content.split(/(```[\s\S]*?```)/g)
  return (
    <div className="prose prose-invert prose-sm max-w-none">
      {parts.map((part, index) => {
        if (part.startsWith('```')) {
          const match = part.match(/^```(\w*)\n?([\s\S]*?)```$/)
          const language = match?.[1] || ''
          const code = match?.[2] || part.slice(3, -3)
          return (
            <pre key={index} className="my-2 overflow-x-auto rounded-lg border border-border bg-raised p-3 text-xs font-mono text-slate-200">
              {language && <div className="mb-2 text-xs font-mono text-dim">{language}</div>}
              <code>{code}</code>
            </pre>
          )
        }
        return <span key={index} className="whitespace-pre-wrap text-sm leading-relaxed">{part}</span>
      })}
    </div>
  )
}

function hydrateMessages(messages: SessionMessage[]): Message[] {
  return messages.map(message => ({
    ...message,
    timestamp: new Date(message.timestamp),
  }))
}

function serializeMessages(messages: Message[]): SessionMessage[] {
  return messages.map(message => ({
    ...message,
    timestamp: message.timestamp.toISOString(),
  }))
}

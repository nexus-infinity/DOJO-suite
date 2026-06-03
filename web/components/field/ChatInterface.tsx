'use client'

import { useEffect, useMemo, useRef, useState } from 'react'
import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'
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

interface Artifact {
  id: string
  type: 'html' | 'code' | 'markdown'
  language: string
  title: string
  code: string        // clean extracted block
  intro: string       // prose before the block
  tail: string        // prose after the block
}

function inferArtifactTitle(intro: string, language: string): string {
  const first = intro.split('\n').find(l => l.trim().length > 3)?.replace(/[*#`_]/g, '').trim()
  if (first && first.length < 80) return first
  const labels: Record<string, string> = {
    html: 'HTML document', css: 'Stylesheet', typescript: 'TypeScript file',
    tsx: 'React component', jsx: 'React component', javascript: 'JavaScript file',
    js: 'JavaScript file', python: 'Python script', sql: 'SQL query',
    json: 'JSON', yaml: 'YAML', markdown: 'Document', md: 'Document',
    bash: 'Shell script', sh: 'Shell script',
  }
  return labels[language.toLowerCase()] ?? `${language} file`
}

function detectArtifact(messageId: string, content: string): Artifact | null {
  // Match first substantial fenced code block
  const fenced = /^([\s\S]*?)```(\w*)\n([\s\S]*?)```([\s\S]*)$/m.exec(content)
  if (fenced) {
    const intro = fenced[1].trim()
    const language = fenced[2] || 'text'
    const code = fenced[3].trim()
    const tail = fenced[4].trim()
    if (code.split('\n').length >= 5) {
      return {
        id: messageId,
        type: language === 'html' ? 'html' : 'code',
        language,
        title: inferArtifactTitle(intro, language),
        code,
        intro,
        tail,
      }
    }
  }
  // Match markdown document (starts with heading, no code blocks, substantial length)
  const mdHeading = /^#{1,3}\s+(.+)/m.exec(content)
  if (mdHeading && content.length > 300 && !content.includes('```')) {
    return {
      id: messageId,
      type: 'markdown',
      language: 'markdown',
      title: mdHeading[1].replace(/[*_`]/g, '').trim(),
      code: content,
      intro: '',
      tail: '',
    }
  }
  return null
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
  const [artifact, setArtifact] = useState<Artifact | null>(null)
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
    setArtifact(null) // clear previous artifact on new message

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

      // Detect artifact after stream completes — pop out as side panel
      const detected = detectArtifact(assistantId, accumulated)
      if (detected) setArtifact(detected)
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
    <div className="flex h-full overflow-hidden">
      {/* LEFT: Chat column */}
      <div className={`flex flex-col ${artifact ? 'w-[44%] border-r border-border' : 'flex-1'} min-w-0`}>
        {topSuggestion && (
          <div className="border-b border-dojo/20 bg-dojo/5 px-4 py-2">
            <div className="flex items-center justify-between gap-4">
              <p className="text-xs text-slate-300">
                {topSuggestion.isAmbiguous ? 'Multiple workstreams match this thread.' : `Continue in workstream — ${topSuggestion.reason}`}
              </p>
              <div className="flex gap-2 shrink-0">
                <button
                  onClick={() => handleAttach(topSuggestion.workstreamId)}
                  disabled={handlingSuggestion}
                  className="rounded-lg border border-dojo/30 bg-dojo/20 px-3 py-1 text-xs text-dojo transition-colors hover:bg-dojo/30 disabled:opacity-50"
                >
                  Continue there
                </button>
                <button
                  onClick={handleSeparate}
                  disabled={handlingSuggestion}
                  className="rounded-lg border border-border px-3 py-1 text-xs text-muted transition-colors hover:text-slate-200 disabled:opacity-50"
                >
                  Keep separate
                </button>
              </div>
            </div>
          </div>
        )}

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
              placeholder="Ask for a concrete task…"
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
                ? '◼︎ DOJO  741 Hz — live task surface; chamber chat still gated'
                : '◼︎ DOJO  741 Hz — chamber route currently offline'}
          </p>
        </div>
      </div>

      {/* RIGHT: Artifact panel — Claude-style canvas */}
      {artifact && <ArtifactPanel artifact={artifact} onClose={() => setArtifact(null)} />}
    </div>
  )
}

function ArtifactPanel({ artifact, onClose }: { artifact: Artifact; onClose: () => void }) {
  const [tab, setTab] = useState<'code' | 'preview'>('code')
  const [copied, setCopied] = useState(false)

  function copyCode() {
    navigator.clipboard.writeText(artifact.code).then(() => {
      setCopied(true)
      setTimeout(() => setCopied(false), 1500)
    })
  }

  const canPreview = artifact.type === 'html' || artifact.type === 'markdown'

  return (
    <div className="flex flex-1 flex-col min-w-0 bg-raised overflow-hidden">
      {/* Header */}
      <div className="flex shrink-0 items-center gap-3 border-b border-border px-4 py-3">
        <div className="flex-1 min-w-0">
          <p className="truncate text-sm font-medium text-slate-100">{artifact.title}</p>
          <p className="font-mono text-xs text-muted mt-0.5">{artifact.language}</p>
        </div>
        <div className="flex items-center gap-2 shrink-0">
          {canPreview && (
            <div className="flex rounded-lg border border-border overflow-hidden text-xs">
              <button
                onClick={() => setTab('code')}
                className={`px-3 py-1 transition-colors ${tab === 'code' ? 'bg-dojo/20 text-dojo' : 'text-muted hover:text-slate-200'}`}
              >
                Code
              </button>
              <button
                onClick={() => setTab('preview')}
                className={`px-3 py-1 border-l border-border transition-colors ${tab === 'preview' ? 'bg-dojo/20 text-dojo' : 'text-muted hover:text-slate-200'}`}
              >
                Preview
              </button>
            </div>
          )}
          <button
            onClick={copyCode}
            className="flex h-7 w-7 items-center justify-center rounded-lg border border-border text-muted transition-colors hover:text-slate-200"
            title="Copy"
          >
            {copied ? '✓' : '⎘'}
          </button>
          <button
            onClick={onClose}
            className="flex h-7 w-7 items-center justify-center rounded-lg border border-border text-muted transition-colors hover:text-slate-200"
            title="Close"
          >
            ✕
          </button>
        </div>
      </div>

      {/* Body */}
      <div className="flex-1 overflow-auto">
        {tab === 'code' || !canPreview ? (
          <pre
            className="h-full p-4 text-xs leading-relaxed text-slate-200 font-mono overflow-auto whitespace-pre-wrap break-words"
            style={{ background: 'transparent' }}
          >
            {artifact.code}
          </pre>
        ) : artifact.type === 'html' ? (
          <iframe
            srcDoc={artifact.code}
            sandbox="allow-scripts"
            className="h-full w-full border-0 bg-white"
            title={artifact.title}
          />
        ) : (
          <div className="p-6 prose prose-invert prose-sm max-w-none
            prose-headings:text-slate-100 prose-p:text-slate-200 prose-li:text-slate-200
            prose-strong:text-slate-100 prose-code:text-dojo prose-code:bg-surface
            prose-code:px-1 prose-code:rounded prose-code:text-xs prose-code:before:content-none prose-code:after:content-none
            prose-pre:bg-surface prose-pre:border prose-pre:border-border prose-pre:rounded-lg prose-pre:p-3 prose-pre:text-xs
            prose-blockquote:border-dojo/40 prose-blockquote:text-muted prose-hr:border-border">
            <ReactMarkdown remarkPlugins={[remarkGfm]}>{artifact.code}</ReactMarkdown>
          </div>
        )}
      </div>
    </div>
  )
}

function EmptyState() {
  return (
    <div className="portal-in flex h-full flex-col items-center justify-center gap-6 py-20">
      <SpellCircle chamber="dojo" size={96} />
      <div className="text-center">
        <h1 className="mb-1 text-2xl font-semibold text-slate-100">DOJO Live Tasks</h1>
        <p className="font-mono text-sm text-muted">◼︎ DOJO  741 Hz — sessions, memory, archive, status</p>
        <p className="mt-3 max-w-xs text-xs text-dim">Ask for a concrete action here. General chamber chat is still gated until a real DOJO/Niama model is seated.</p>
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

  return (
    <div className="prose prose-invert prose-sm max-w-none text-slate-100
      prose-p:my-1 prose-p:leading-relaxed
      prose-headings:text-slate-100 prose-headings:font-semibold
      prose-strong:text-slate-100 prose-strong:font-semibold
      prose-code:text-dojo prose-code:bg-raised prose-code:px-1 prose-code:py-0.5 prose-code:rounded prose-code:text-xs prose-code:font-mono prose-code:before:content-none prose-code:after:content-none
      prose-pre:bg-raised prose-pre:border prose-pre:border-border prose-pre:rounded-lg prose-pre:p-3 prose-pre:text-xs
      prose-ul:my-1 prose-ol:my-1 prose-li:my-0.5
      prose-blockquote:border-dojo/40 prose-blockquote:text-muted
      prose-hr:border-border">
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        components={{
          pre: ({ node: _n, className: _c, ...props }) => (
            <pre style={{ margin: '8px 0', overflowX: 'auto', borderRadius: '8px', border: '1px solid #2A2A40', background: '#1A1A2E', padding: '12px', fontSize: '12px', fontFamily: 'monospace', color: '#e2e8f0' }} {...props} />
          ),
          code: ({ node: _n, className: _c, ...props }) => (
            <code style={{ color: '#7C3AED', background: '#1A1A2E', padding: '1px 4px', borderRadius: '4px', fontSize: '12px', fontFamily: 'monospace' }} {...props} />
          ),
        }}
      >
        {content}
      </ReactMarkdown>
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

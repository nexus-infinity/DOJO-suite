'use client'

import { useRef, useState } from 'react'
import { SpellCircle } from './SpellCircle'

type ArtifactType = 'code' | 'html' | 'svg' | 'markdown'

interface Artifact {
  id: string
  type: ArtifactType
  title: string
  language?: string
  content: string
  chamber: string
}

const STARTER_PROMPTS = [
  { label: 'Chamber health check', prompt: 'Write a TypeScript function that checks health of all 6 FIELD chambers (DOJO :7410, OBI-WAN :9630, ATLAS :5280, TATA :4320, AKRON :3960, ARKADAŠ :7170) via fetch and returns their status.' },
  { label: 'Python health check', prompt: 'Write a Python script to check all FIELD chamber endpoints via httpx and print a status table.' },
  { label: 'Streaming chat API route', prompt: 'Write a Next.js 15 API route (app router) for streaming chat with an Ollama model, using SSE.' },
  { label: 'Swift MCP client', prompt: 'Write a Swift struct that connects to a FIELD chamber MCP server at a given URL and calls a named tool with JSON parameters.' },
  { label: 'LoRA training config', prompt: 'Write a Python dataclass config for LoRA fine-tuning a Phi-3-mini-4k-instruct model using HuggingFace PEFT, with 4-bit quantization.' },
]

function detectType(content: string): { type: ArtifactType; language?: string } {
  const trimmed = content.trim()
  if (trimmed.startsWith('<html') || trimmed.startsWith('<!DOCTYPE')) return { type: 'html' }
  if (trimmed.startsWith('<svg')) return { type: 'svg' }
  if (trimmed.startsWith('#') || trimmed.startsWith('**')) return { type: 'markdown' }
  // detect language from first fence or content heuristics
  const pyMatch = content.match(/```(python|py)\b/)
  const tsMatch = content.match(/```(typescript|ts|tsx)\b/)
  const swiftMatch = content.match(/```swift\b/)
  const jsMatch = content.match(/```(javascript|js)\b/)
  if (pyMatch) return { type: 'code', language: 'python' }
  if (tsMatch) return { type: 'code', language: 'typescript' }
  if (swiftMatch) return { type: 'code', language: 'swift' }
  if (jsMatch) return { type: 'code', language: 'javascript' }
  return { type: 'code', language: 'typescript' }
}

function extractCode(raw: string): string {
  // strip markdown fences if present
  const fenced = raw.match(/```(?:\w+)?\n([\s\S]*?)```/)
  return fenced ? fenced[1].trim() : raw.trim()
}

export function CodeArtifact() {
  const [artifact, setArtifact] = useState<Artifact | null>(null)
  const [streaming, setStreaming] = useState(false)
  const [activeTab, setActiveTab] = useState<'code' | 'preview'>('code')
  const [copied, setCopied] = useState(false)
  const [input, setInput] = useState('')
  const accRef = useRef('')

  async function runPrompt(promptText: string, title: string) {
    if (streaming) return
    setStreaming(true)
    accRef.current = ''

    const newArtifact: Artifact = {
      id: crypto.randomUUID(),
      type: 'code',
      language: 'typescript',
      title,
      content: '',
      chamber: 'dojo',
    }
    setArtifact(newArtifact)
    setActiveTab('code')

    try {
      const res = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: promptText,
          conversationId: `code-${newArtifact.id}`,
          history: [],
        }),
      })

      if (!res.body) throw new Error('No response body')
      const reader = res.body.getReader()
      const decoder = new TextDecoder()

      while (true) {
        const { done, value } = await reader.read()
        if (done) break
        for (const line of decoder.decode(value, { stream: true }).split('\n')) {
          if (!line.startsWith('data: ')) continue
          try {
            const data = JSON.parse(line.slice(6))
            if (data.content) {
              accRef.current += data.content
              const raw = accRef.current
              const { type, language } = detectType(raw)
              setArtifact(prev => prev ? { ...prev, type, language, content: raw } : prev)
            }
          } catch { /* skip */ }
        }
      }

      // Final pass: strip fences for clean display
      setArtifact(prev => {
        if (!prev) return prev
        const clean = extractCode(accRef.current)
        const { type, language } = detectType(clean)
        return { ...prev, type, language, content: clean }
      })
    } catch (err) {
      setArtifact(prev => prev ? { ...prev, content: `// Error: ${String(err)}` } : prev)
    } finally {
      setStreaming(false)
    }
  }

  async function copy() {
    if (!artifact) return
    await navigator.clipboard.writeText(artifact.content)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  function onKeyDown(e: React.KeyboardEvent) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      const trimmed = input.trim()
      if (trimmed) runPrompt(trimmed, trimmed.slice(0, 48))
    }
  }

  return (
    <div className="flex h-full">

      {/* Left — prompt pane */}
      <div className="w-80 shrink-0 border-r border-border flex flex-col bg-surface">
        <div className="px-4 py-3 border-b border-border">
          <h2 className="text-sm font-semibold text-slate-300">Code workspace</h2>
          <p className="text-xs text-muted mt-0.5">Ask NIAMA to generate, refactor, or explain code</p>
        </div>

        <div className="flex-1 p-4 space-y-2 overflow-y-auto">
          {STARTER_PROMPTS.map(({ label, prompt }) => (
            <button
              key={label}
              onClick={() => runPrompt(prompt, label)}
              disabled={streaming}
              className="w-full text-left text-xs text-muted hover:text-slate-300 px-3 py-2.5 rounded-lg bg-raised hover:bg-border transition-colors leading-snug disabled:opacity-40 disabled:cursor-not-allowed"
            >
              {label}
            </button>
          ))}
        </div>

        {/* Custom prompt input */}
        <div className="p-3 border-t border-border space-y-2">
          <textarea
            value={input}
            onChange={e => setInput(e.target.value)}
            onKeyDown={onKeyDown}
            placeholder="Custom prompt… (Enter to send)"
            rows={3}
            disabled={streaming}
            className="w-full resize-none rounded-lg bg-raised border border-border text-xs text-slate-200 placeholder:text-dim px-3 py-2 focus:outline-none focus:border-dojo/50 disabled:opacity-40"
          />
          <button
            onClick={() => { const t = input.trim(); if (t) runPrompt(t, t.slice(0, 48)) }}
            disabled={streaming || !input.trim()}
            className="w-full py-1.5 rounded-lg text-xs font-medium bg-dojo/20 text-dojo hover:bg-dojo/30 transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
          >
            {streaming ? 'Generating…' : 'Generate ◈'}
          </button>
          <div className="flex items-center gap-2 text-xs text-dim font-mono pt-1">
            <SpellCircle chamber="dojo" size={16} compact />
            <span>◼︎ 741 Hz</span>
          </div>
        </div>
      </div>

      {/* Right — artifact viewer */}
      <div className="flex-1 flex flex-col min-w-0">

        {!artifact && !streaming && (
          <div className="flex-1 flex items-center justify-center">
            <div className="text-center space-y-2">
              <SpellCircle chamber="dojo" size={48} compact />
              <p className="text-muted text-sm">Select a prompt or write your own</p>
            </div>
          </div>
        )}

        {artifact && (
          <>
            <div className="flex items-center justify-between px-4 py-2.5 border-b border-border bg-surface shrink-0">
              <div className="flex items-center gap-3">
                <SpellCircle chamber="dojo" size={20} compact />
                <span className="text-sm font-medium text-slate-200">{artifact.title}</span>
                {artifact.language && (
                  <span className="text-xs font-mono text-dojo bg-dojo/10 px-2 py-0.5 rounded">{artifact.language}</span>
                )}
                {streaming && <span className="text-xs text-muted animate-pulse">generating…</span>}
              </div>

              <div className="flex items-center gap-2">
                <div className="flex gap-1 bg-raised rounded-lg p-0.5">
                  {(['code', 'preview'] as const).map(tab => (
                    <button
                      key={tab}
                      onClick={() => setActiveTab(tab)}
                      className={`px-3 py-1 rounded text-xs font-medium transition-all ${
                        activeTab === tab ? 'bg-surface text-slate-200' : 'text-muted hover:text-slate-300'
                      }`}
                    >
                      {tab === 'code' ? '⟨/⟩ Code' : '⬡ Preview'}
                    </button>
                  ))}
                </div>
                <button
                  onClick={copy}
                  className="text-xs text-muted hover:text-slate-300 px-2 py-1 rounded transition-colors"
                >
                  {copied ? '✓ Copied' : 'Copy'}
                </button>
              </div>
            </div>

            {activeTab === 'code' && (
              <div className="flex-1 overflow-auto">
                <pre className="p-6 text-sm font-mono text-slate-200 leading-relaxed min-h-full whitespace-pre-wrap">
                  <code>{artifact.content}</code>
                </pre>
              </div>
            )}

            {activeTab === 'preview' && (
              <div className="flex-1 overflow-auto bg-white">
                {artifact.type === 'html'
                  ? <iframe srcDoc={artifact.content} className="w-full h-full border-0" title="Preview" />
                  : <div className="flex items-center justify-center h-full bg-raised">
                      <p className="text-muted text-sm">Preview available for HTML artifacts only</p>
                    </div>
                }
              </div>
            )}
          </>
        )}
      </div>
    </div>
  )
}

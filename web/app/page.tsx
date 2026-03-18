// ◼︎ DOJO Web — main page
// Three-mode interface: Chat | Code | Collaborate
// Left: sidebar (history + chambers) | Centre: active mode | Right: MCP panel (toggleable)

'use client'

import { startTransition, useEffect, useMemo, useRef, useState } from 'react'
import { ChatInterface } from '@/components/field/ChatInterface'
import { CodeArtifact } from '@/components/field/CodeArtifact'
import { CollabPanel } from '@/components/field/CollabPanel'
import { ChamberSidebar } from '@/components/field/ChamberSidebar'
import { MCPPanel } from '@/components/field/MCPPanel'
import { SpellCircle } from '@/components/field/SpellCircle'
import type { PersonalMemoryItem, Workstream, WorkstreamSuggestion } from '@/lib/memoryTypes'
import {
  createSessionId,
  inferSessionTitle,
  sessionPreview,
  type SessionMessage,
  type SessionMode,
  type SessionRecord,
} from '@/lib/sessionStore'

interface SessionsPayload {
  sessions: SessionRecord[]
  greyZone: SessionRecord[]
  dormant: SessionRecord[]
  archive: SessionRecord[]
  greyZoneDays: number
}

interface WorkstreamsPayload {
  workstreams: Workstream[]
  activeThisWeek: Workstream[]
  greyZone: Workstream[]
  dormant: Workstream[]
  greyZoneDays: number
}

interface MemoryPayload {
  items: PersonalMemoryItem[]
  greyZoneDays: number
}

interface ArchiveSearchResult {
  id: string
  title: string
  summary: string
  updatedAt: string
  archivedAt: string | null
  primaryWorkstreamId: string | null
}

const EMPTY_SESSIONS: SessionsPayload = {
  sessions: [],
  greyZone: [],
  dormant: [],
  archive: [],
  greyZoneDays: 30,
}

const EMPTY_WORKSTREAMS: WorkstreamsPayload = {
  workstreams: [],
  activeThisWeek: [],
  greyZone: [],
  dormant: [],
  greyZoneDays: 30,
}

const EMPTY_MEMORY: MemoryPayload = {
  items: [],
  greyZoneDays: 30,
}

export default function DOJOPage() {
  const [mode, setMode] = useState<SessionMode>('chat')
  const [mcpOpen, setMcpOpen] = useState(false)
  const [sessionsState, setSessionsState] = useState<SessionsPayload>(EMPTY_SESSIONS)
  const [workstreamsState, setWorkstreamsState] = useState<WorkstreamsPayload>(EMPTY_WORKSTREAMS)
  const [memoryState, setMemoryState] = useState<MemoryPayload>(EMPTY_MEMORY)
  const [activeSessionId, setActiveSessionId] = useState<string>('')
  const [dojoOnline, setDojoOnline] = useState(false)
  const [suggestions, setSuggestions] = useState<WorkstreamSuggestion[]>([])
  const [archiveResults, setArchiveResults] = useState<ArchiveSearchResult[]>([])
  const persistTimer = useRef<number | null>(null)

  const activeSession = useMemo(
    () => sessionsState.sessions.find(session => session.id === activeSessionId) ?? sessionsState.sessions[0] ?? null,
    [activeSessionId, sessionsState.sessions]
  )

  useEffect(() => {
    let cancelled = false

    async function bootstrap() {
      const [sessions, workstreams, memory] = await Promise.all([
        fetchJson<SessionsPayload>('/api/sessions'),
        fetchJson<WorkstreamsPayload>('/api/workstreams'),
        fetchJson<MemoryPayload>('/api/memory/personal'),
      ])

      if (cancelled) return

      const preferred = sessions.sessions[0]

      startTransition(() => {
        setSessionsState(sessions)
        setWorkstreamsState(workstreams)
        setMemoryState(memory)
        if (preferred) {
          setActiveSessionId(preferred.id)
          setMode(preferred.mode)
        }
      })

      if (preferred) return

      await createNewSession('chat')
    }

    bootstrap()
    return () => {
      cancelled = true
    }
  }, [])

  useEffect(() => {
    let cancelled = false

    async function loadHealth() {
      try {
        const res = await fetch('/api/health', { cache: 'no-store' })
        if (!res.ok) throw new Error(`HTTP ${res.status}`)
        const payload = await res.json()
        if (!cancelled) setDojoOnline(payload?.chambers?.dojo?.normalizedStatus === 'alive')
      } catch {
        if (!cancelled) setDojoOnline(false)
      }
    }

    loadHealth()
    const interval = window.setInterval(loadHealth, 15_000)
    return () => {
      cancelled = true
      window.clearInterval(interval)
    }
  }, [])

  useEffect(() => {
    if (!activeSession) return
    setMode(activeSession.mode)
  }, [activeSession])

  useEffect(() => {
    if (!activeSession || activeSession.status === 'archived' || activeSession.messages.length === 0) {
      setSuggestions([])
      return
    }

    let cancelled = false
    const handle = window.setTimeout(async () => {
      const payload = await fetchJson<{ suggestions: WorkstreamSuggestion[] }>('/api/workstreams/suggest', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ sessionId: activeSession.id }),
      })
      if (!cancelled) setSuggestions(payload.suggestions)
    }, 350)

    return () => {
      cancelled = true
      window.clearTimeout(handle)
    }
  }, [activeSession?.id, activeSession?.messages.length, activeSession?.primaryWorkstreamId, activeSession?.status])

  async function refreshPanels() {
    const [workstreams, memory] = await Promise.all([
      fetchJson<WorkstreamsPayload>('/api/workstreams'),
      fetchJson<MemoryPayload>('/api/memory/personal'),
    ])

    startTransition(() => {
      setWorkstreamsState(workstreams)
      setMemoryState(memory)
    })
  }

  async function createNewSession(nextMode: SessionMode = 'chat') {
    const payload = await fetchJson<{ session: SessionRecord | null } & SessionsPayload>('/api/sessions', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        id: createSessionId(),
        title: 'New session',
        mode: nextMode,
      }),
    })

    setSessionsState(payload)
    if (payload.session) {
      setActiveSessionId(payload.session.id)
      setMode(nextMode)
    }
    await refreshPanels()
  }

  async function persistSessionPatch(sessionId: string, patch: Partial<{
    title: string
    mode: SessionMode
    status: 'active' | 'archived'
    messages: SessionMessage[]
    summary: string
    includeArchive: boolean
  }>) {
    const payload = await fetchJson<{ session: SessionRecord | null } & SessionsPayload>('/api/sessions', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: sessionId, ...patch }),
    })

    setSessionsState(payload)
    if (payload.session) {
      setActiveSessionId(payload.session.id)
    }
    await refreshPanels()
  }

  function updateSessionLocally(sessionId: string, updater: (session: SessionRecord) => SessionRecord) {
    setSessionsState(prev => ({
      ...prev,
      sessions: prev.sessions.map(session => session.id === sessionId ? updater(session) : session),
      greyZone: prev.greyZone.map(session => session.id === sessionId ? updater(session) : session),
      dormant: prev.dormant.map(session => session.id === sessionId ? updater(session) : session),
      archive: prev.archive.map(session => session.id === sessionId ? updater(session) : session),
    }))
  }

  function scheduleSessionPersist(sessionId: string, patchFactory: () => Partial<{
    title: string
    mode: SessionMode
    status: 'active' | 'archived'
    messages: SessionMessage[]
    summary: string
    includeArchive: boolean
  }>) {
    if (persistTimer.current) window.clearTimeout(persistTimer.current)
    persistTimer.current = window.setTimeout(() => {
      persistSessionPatch(sessionId, patchFactory())
    }, 400)
  }

  function handleMessagesChange(messages: SessionMessage[]) {
    if (!activeSession) return
    const title = inferSessionTitle(messages)
    const summary = sessionPreview(messages)

    updateSessionLocally(activeSession.id, session => ({
      ...session,
      title,
      summary,
      mode: 'chat',
      messages,
      updatedAt: new Date().toISOString(),
      lastActiveAt: messages.at(-1)?.timestamp ?? session.lastActiveAt,
    }))

    scheduleSessionPersist(activeSession.id, () => ({
      title,
      summary,
      messages,
      mode: 'chat',
    }))
  }

  function handleRenameSession(sessionId: string, title: string) {
    const clean = title.trim()
    if (!clean) return
    updateSessionLocally(sessionId, session => ({ ...session, title: clean, updatedAt: new Date().toISOString() }))
    persistSessionPatch(sessionId, { title: clean })
  }

  async function handleArchiveSession(sessionId: string) {
    await persistSessionPatch(sessionId, { status: 'archived' })
    if (activeSessionId === sessionId) {
      const next = sessionsState.sessions.find(session => session.id !== sessionId && session.status === 'active')
      if (next) {
        setActiveSessionId(next.id)
      } else {
        await createNewSession('chat')
      }
    }
  }

  async function handleToggleArchive(sessionId: string, includeArchive: boolean) {
    updateSessionLocally(sessionId, session => ({ ...session, includeArchive, updatedAt: new Date().toISOString() }))
    await persistSessionPatch(sessionId, { includeArchive })
  }

  async function handlePromoteSession(sessionId: string) {
    const session = sessionsState.sessions.find(item => item.id === sessionId)
    if (!session) return
    await fetchJson('/api/workstreams', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        id: `ws-${sessionId}`,
        name: session.title,
        summary: session.summary,
        sessionId,
        linkReason: 'manual-promote',
        linkScore: 1,
      }),
    })
    await refreshAll()
  }

  async function refreshAll() {
    const [sessions, workstreams, memory] = await Promise.all([
      fetchJson<SessionsPayload>('/api/sessions'),
      fetchJson<WorkstreamsPayload>('/api/workstreams'),
      fetchJson<MemoryPayload>('/api/memory/personal'),
    ])
    setSessionsState(sessions)
    setWorkstreamsState(workstreams)
    setMemoryState(memory)
  }

  async function handleWorkstreamUpdate(workstreamId: string, patch: Record<string, unknown>) {
    await fetchJson('/api/workstreams', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: workstreamId, ...patch }),
    })
    await refreshAll()
  }

  async function handleAttachWorkstream(workstreamId: string) {
    if (!activeSession) return
    await fetchJson('/api/workstreams/attach-session', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ sessionId: activeSession.id, workstreamId }),
    })
    setSuggestions([])
    await refreshAll()
  }

  async function handleKeepSeparate() {
    if (!activeSession) return
    await Promise.all(
      suggestions.slice(0, 2).map(suggestion =>
        fetchJson('/api/workstreams/detach-session', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ sessionId: activeSession.id, workstreamId: suggestion.workstreamId }),
        })
      )
    )
    setSuggestions([])
    await refreshAll()
  }

  async function handleDetachSession(workstreamId: string, sessionId: string) {
    await fetchJson('/api/workstreams/detach-session', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ workstreamId, sessionId }),
    })
    await refreshAll()
  }

  async function handleMergeWorkstreams(sourceId: string, targetId: string) {
    await fetchJson('/api/workstreams/merge', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ sourceId, targetId }),
    })
    await refreshAll()
  }

  async function handleMemoryUpdate(payload: Record<string, unknown>) {
    await fetchJson('/api/memory/personal', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    })
    await refreshAll()
  }

  async function handlePromotionReview(id: string, action: 'confirm' | 'demote' | 'delete') {
    await fetchJson('/api/memory/promotions/review', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id, action }),
    })
    await refreshAll()
  }

  async function handleCreatePersonalMemory(content: string) {
    await fetchJson('/api/memory/personal', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        id: `mem-manual-${Date.now()}`,
        kind: 'manual',
        content,
        source: 'manual-entry',
        confidence: 1,
        status: 'confirmed',
      }),
    })
    await refreshAll()
  }

  async function handleArchiveSearch(query: string) {
    if (!query.trim()) {
      setArchiveResults([])
      return
    }
    const payload = await fetchJson<{ results: ArchiveSearchResult[] }>(`/api/archive/search?q=${encodeURIComponent(query)}`)
    setArchiveResults(payload.results)
  }

  if (!activeSession) {
    return <div className="flex h-screen items-center justify-center bg-void text-slate-100">Loading FIELD…</div>
  }

  return (
    <div className="flex h-screen overflow-hidden bg-void text-slate-100">
      <ChamberSidebar
        sessions={sessionsState.sessions.filter(session => session.status === 'active')}
        activeSessionId={activeSession.id}
        onSelectSession={setActiveSessionId}
        onNewSession={() => createNewSession('chat')}
      />

      <div className="flex flex-col flex-1 min-w-0">
        <header className="flex items-center justify-between px-4 py-3 border-b border-border bg-surface shrink-0">
          <div className="flex items-center gap-3">
            <SpellCircle chamber="dojo" size={32} compact />
            <div>
              <span className="font-mono text-sm font-semibold text-dojo">◼︎ DOJO</span>
              <span className="ml-2 font-mono text-xs text-muted">741 Hz — Manifestation apex</span>
            </div>
          </div>

          <nav className="flex gap-1 bg-raised rounded-lg p-1">
            {(['chat', 'code', 'collab'] as SessionMode[]).map(nextMode => (
              <button
                key={nextMode}
                onClick={() => {
                  setMode(nextMode)
                  updateSessionLocally(activeSession.id, session => ({ ...session, mode: nextMode, updatedAt: new Date().toISOString() }))
                  persistSessionPatch(activeSession.id, { mode: nextMode })
                }}
                className={`px-4 py-1.5 rounded-md text-sm font-medium transition-all ${
                  mode === nextMode ? 'bg-dojo/20 text-dojo shadow-sm' : 'text-muted hover:text-slate-300'
                }`}
              >
                {nextMode === 'chat' ? '◈ Chat' : nextMode === 'code' ? '⟨/⟩ Code' : '◫ Memory'}
              </button>
            ))}
          </nav>

          <button
            onClick={() => setMcpOpen(open => !open)}
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

        <main className="flex-1 overflow-hidden">
          {mode === 'chat' && (
            <ChatInterface
              key={activeSession.id}
              conversationId={activeSession.id}
              messages={activeSession.messages}
              includeArchive={activeSession.includeArchive}
              suggestions={activeSession.primaryWorkstreamId ? [] : suggestions}
              onMessagesChange={handleMessagesChange}
              chamberConnected={dojoOnline}
              onToggleIncludeArchive={value => handleToggleArchive(activeSession.id, value)}
              onAttachWorkstream={handleAttachWorkstream}
              onKeepSeparate={handleKeepSeparate}
            />
          )}
          {mode === 'code' && <CodeArtifact />}
          {mode === 'collab' && (
            <CollabPanel
              sessionsState={sessionsState}
              workstreamsState={workstreamsState}
              memoryState={memoryState}
              activeSessionId={activeSession.id}
              archiveResults={archiveResults}
              onSelectSession={setActiveSessionId}
              onOpenChat={sessionId => {
                setActiveSessionId(sessionId)
                setMode('chat')
              }}
              onRenameSession={handleRenameSession}
              onArchiveSession={handleArchiveSession}
              onPromoteSession={handlePromoteSession}
              onWorkstreamUpdate={handleWorkstreamUpdate}
              onWorkstreamDetach={handleDetachSession}
              onWorkstreamMerge={handleMergeWorkstreams}
              onMemoryUpdate={handleMemoryUpdate}
              onPromotionReview={handlePromotionReview}
              onCreatePersonalMemory={handleCreatePersonalMemory}
              onArchiveSearch={handleArchiveSearch}
            />
          )}
        </main>
      </div>

      {mcpOpen && <MCPPanel onClose={() => setMcpOpen(false)} />}
    </div>
  )
}

async function fetchJson<T>(input: RequestInfo | URL, init?: RequestInit) {
  const res = await fetch(input, init)
  if (!res.ok) {
    throw new Error(`HTTP ${res.status}`)
  }
  return res.json() as Promise<T>
}

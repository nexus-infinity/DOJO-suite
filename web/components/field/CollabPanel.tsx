'use client'

import { useEffect, useMemo, useState } from 'react'
import { SpellCircle } from './SpellCircle'
import {
  type PersonalMemoryItem,
  type SessionRecord,
  type Workstream,
  formatRelativeSessionTime,
  sessionPreview,
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

interface Props {
  sessionsState: SessionsPayload
  workstreamsState: WorkstreamsPayload
  memoryState: MemoryPayload
  activeSessionId: string
  archiveResults: ArchiveSearchResult[]
  onSelectSession: (sessionId: string) => void
  onOpenChat: (sessionId: string) => void
  onRenameSession: (sessionId: string, title: string) => void
  onArchiveSession: (sessionId: string) => Promise<void> | void
  onPromoteSession: (sessionId: string) => Promise<void> | void
  onWorkstreamUpdate: (workstreamId: string, patch: Record<string, unknown>) => Promise<void> | void
  onWorkstreamDetach: (workstreamId: string, sessionId: string) => Promise<void> | void
  onWorkstreamMerge: (sourceId: string, targetId: string) => Promise<void> | void
  onMemoryUpdate: (payload: Record<string, unknown>) => Promise<void> | void
  onPromotionReview: (id: string, action: 'confirm' | 'demote' | 'delete') => Promise<void> | void
  onCreatePersonalMemory: (content: string) => Promise<void> | void
  onArchiveSearch: (query: string) => Promise<void> | void
}

export function CollabPanel({
  sessionsState,
  workstreamsState,
  memoryState,
  activeSessionId,
  archiveResults,
  onSelectSession,
  onOpenChat,
  onRenameSession,
  onArchiveSession,
  onPromoteSession,
  onWorkstreamUpdate,
  onWorkstreamDetach,
  onWorkstreamMerge,
  onMemoryUpdate,
  onPromotionReview,
  onCreatePersonalMemory,
  onArchiveSearch,
}: Props) {
  const [newMemory, setNewMemory] = useState('')
  const [archiveQuery, setArchiveQuery] = useState('')
  const [greyZoneDaysInput, setGreyZoneDaysInput] = useState(String(memoryState.greyZoneDays))
  const [sessionTitles, setSessionTitles] = useState<Record<string, string>>({})
  const [memoryDrafts, setMemoryDrafts] = useState<Record<string, string>>({})
  const [workstreamDrafts, setWorkstreamDrafts] = useState<Record<string, { name: string; summary: string; archiveAfterDays: string }>>({})
  const [mergeTargets, setMergeTargets] = useState<Record<string, string>>({})

  const activeSession = useMemo(
    () => sessionsState.sessions.find(session => session.id === activeSessionId) ?? null,
    [activeSessionId, sessionsState.sessions]
  )

  useEffect(() => {
    setGreyZoneDaysInput(String(memoryState.greyZoneDays))
  }, [memoryState.greyZoneDays])

  useEffect(() => {
    setSessionTitles(prev => {
      const next = { ...prev }
      for (const session of sessionsState.sessions) {
        if (!(session.id in next)) next[session.id] = session.title
      }
      return next
    })
  }, [sessionsState.sessions])

  useEffect(() => {
    setMemoryDrafts(prev => {
      const next = { ...prev }
      for (const item of memoryState.items) {
        if (!(item.id in next)) next[item.id] = item.content
      }
      return next
    })
  }, [memoryState.items])

  useEffect(() => {
    setWorkstreamDrafts(prev => {
      const next = { ...prev }
      for (const workstream of workstreamsState.workstreams) {
        if (!(workstream.id in next)) {
          next[workstream.id] = {
            name: workstream.name,
            summary: workstream.summary,
            archiveAfterDays: String(workstream.archiveAfterDays),
          }
        }
      }
      return next
    })
  }, [workstreamsState.workstreams])

  async function handleGreyZoneSave() {
    const days = Number(greyZoneDaysInput)
    if (!Number.isFinite(days)) return
    await onMemoryUpdate({ greyZoneDays: days })
  }

  async function handleSessionRename(sessionId: string) {
    const title = sessionTitles[sessionId]?.trim()
    if (!title) return
    await onRenameSession(sessionId, title)
  }

  async function handleMemorySave(item: PersonalMemoryItem) {
    const content = memoryDrafts[item.id]?.trim()
    if (!content) return
    await onMemoryUpdate({ id: item.id, content })
  }

  async function handleWorkstreamSave(workstream: Workstream) {
    const draft = workstreamDrafts[workstream.id]
    if (!draft) return
    const archiveAfterDays = Number(draft.archiveAfterDays)
    await onWorkstreamUpdate(workstream.id, {
      name: draft.name.trim() || workstream.name,
      summary: draft.summary.trim(),
      archiveAfterDays: Number.isFinite(archiveAfterDays) ? archiveAfterDays : workstream.archiveAfterDays,
    })
  }

  const visibleRecentSessions = useMemo(
    () => [...sessionsState.greyZone].sort((a, b) => Date.parse(b.updatedAt) - Date.parse(a.updatedAt)),
    [sessionsState.greyZone]
  )

  return (
    <div className="grid h-full min-h-0 grid-cols-1 gap-px overflow-hidden bg-border xl:grid-cols-3">
      <section className="flex min-h-0 flex-col bg-surface">
        <div className="border-b border-border px-4 py-4">
          <div className="flex items-center gap-3">
            <SpellCircle chamber="obiwan" size={22} compact />
            <div>
              <h2 className="text-sm font-semibold text-slate-100">Personal Memory</h2>
              <p className="text-xs text-muted">Cross-chat memory. Draft items remain low-authority until confirmed.</p>
            </div>
          </div>
          <div className="mt-4 flex gap-2">
            <textarea
              value={newMemory}
              onChange={event => setNewMemory(event.target.value)}
              rows={2}
              placeholder="Add confirmed memory that should survive across chats…"
              className="flex-1 rounded-xl border border-border bg-raised px-3 py-2 text-sm text-slate-100 outline-none placeholder:text-dim"
            />
            <button
              onClick={async () => {
                const content = newMemory.trim()
                if (!content) return
                await onCreatePersonalMemory(content)
                setNewMemory('')
              }}
              className="rounded-xl border border-dojo/30 bg-dojo/20 px-3 py-2 text-sm text-dojo transition-colors hover:bg-dojo/30"
            >
              Add
            </button>
          </div>
          <div className="mt-3 flex items-center gap-2">
            <label className="text-xs font-mono text-dim">Grey zone days</label>
            <input
              type="number"
              min={7}
              max={180}
              value={greyZoneDaysInput}
              onChange={event => setGreyZoneDaysInput(event.target.value)}
              className="w-20 rounded-lg border border-border bg-raised px-2 py-1 text-sm text-slate-100 outline-none"
            />
            <button
              onClick={handleGreyZoneSave}
              className="rounded-lg border border-border px-2.5 py-1 text-xs text-muted transition-colors hover:text-slate-100"
            >
              Save
            </button>
          </div>
        </div>

        <div className="min-h-0 flex-1 space-y-3 overflow-y-auto px-4 py-4">
          {memoryState.items.map(item => (
            <article key={item.id} className="rounded-2xl border border-border bg-raised/70 p-3">
              <div className="mb-2 flex items-center justify-between gap-2">
                <div className="flex items-center gap-2">
                  <span className={`rounded-full px-2 py-0.5 text-[11px] font-mono uppercase ${
                    item.status === 'confirmed'
                      ? 'bg-green-500/10 text-green-300'
                      : item.status === 'draft'
                        ? 'bg-amber-500/10 text-amber-300'
                        : 'bg-slate-500/10 text-slate-400'
                  }`}>
                    {item.status}
                  </span>
                  <span className="text-xs text-dim">{item.kind}</span>
                </div>
                <span className="text-xs text-dim">{Math.round(item.confidence * 100)}%</span>
              </div>
              <textarea
                value={memoryDrafts[item.id] ?? item.content}
                onChange={event => setMemoryDrafts(prev => ({ ...prev, [item.id]: event.target.value }))}
                rows={3}
                className="w-full rounded-xl border border-border bg-surface px-3 py-2 text-sm text-slate-100 outline-none"
              />
              <p className="mt-2 text-xs text-dim">
                Source: {item.source} • Updated {formatRelativeSessionTime(item.updatedAt)}
              </p>
              <div className="mt-3 flex flex-wrap gap-2">
                <button
                  onClick={() => handleMemorySave(item)}
                  className="rounded-lg border border-border px-2.5 py-1 text-xs text-muted transition-colors hover:text-slate-100"
                >
                  Save
                </button>
                {item.status !== 'confirmed' && (
                  <button
                    onClick={() => onPromotionReview(item.id, 'confirm')}
                    className="rounded-lg border border-green-400/30 bg-green-400/10 px-2.5 py-1 text-xs text-green-300"
                  >
                    Confirm
                  </button>
                )}
                {item.status !== 'demoted' && (
                  <button
                    onClick={() => onPromotionReview(item.id, 'demote')}
                    className="rounded-lg border border-amber-400/30 bg-amber-400/10 px-2.5 py-1 text-xs text-amber-300"
                  >
                    Demote
                  </button>
                )}
                <button
                  onClick={() => onPromotionReview(item.id, 'delete')}
                  className="rounded-lg border border-red-400/30 bg-red-400/10 px-2.5 py-1 text-xs text-red-300"
                >
                  Delete
                </button>
              </div>
            </article>
          ))}
          {memoryState.items.length === 0 && (
            <div className="rounded-2xl border border-dashed border-border p-4 text-sm text-dim">
              No personal memory items yet. Confirm durable facts here rather than leaving them trapped inside old sessions.
            </div>
          )}
        </div>
      </section>

      <section className="flex min-h-0 flex-col bg-surface">
        <div className="border-b border-border px-4 py-4">
          <div className="flex items-center gap-3">
            <SpellCircle chamber="arkadas" size={22} compact />
            <div>
              <h2 className="text-sm font-semibold text-slate-100">Workstreams</h2>
              <p className="text-xs text-muted">Discoverable clusters. Ranking aids only, never hard ownership boundaries.</p>
            </div>
          </div>
        </div>

        <div className="min-h-0 flex-1 space-y-5 overflow-y-auto px-4 py-4">
          <WorkstreamSection
            title="Active this week"
            items={workstreamsState.activeThisWeek}
            activeSession={activeSession}
            workstreamDrafts={workstreamDrafts}
            mergeTargets={mergeTargets}
            allWorkstreams={workstreamsState.workstreams}
            onDraftChange={(id, patch) => setWorkstreamDrafts(prev => ({ ...prev, [id]: { ...prev[id], ...patch } }))}
            onMergeTargetChange={(id, targetId) => setMergeTargets(prev => ({ ...prev, [id]: targetId }))}
            onSave={handleWorkstreamSave}
            onWorkstreamUpdate={onWorkstreamUpdate}
            onDetach={onWorkstreamDetach}
            onMerge={onWorkstreamMerge}
          />
          <WorkstreamSection
            title={`Active in grey zone (${workstreamsState.greyZoneDays} days)`}
            items={workstreamsState.greyZone}
            activeSession={activeSession}
            workstreamDrafts={workstreamDrafts}
            mergeTargets={mergeTargets}
            allWorkstreams={workstreamsState.workstreams}
            onDraftChange={(id, patch) => setWorkstreamDrafts(prev => ({ ...prev, [id]: { ...prev[id], ...patch } }))}
            onMergeTargetChange={(id, targetId) => setMergeTargets(prev => ({ ...prev, [id]: targetId }))}
            onSave={handleWorkstreamSave}
            onWorkstreamUpdate={onWorkstreamUpdate}
            onDetach={onWorkstreamDetach}
            onMerge={onWorkstreamMerge}
          />
          <WorkstreamSection
            title="Dormant but relevant"
            items={workstreamsState.dormant}
            activeSession={activeSession}
            workstreamDrafts={workstreamDrafts}
            mergeTargets={mergeTargets}
            allWorkstreams={workstreamsState.workstreams}
            onDraftChange={(id, patch) => setWorkstreamDrafts(prev => ({ ...prev, [id]: { ...prev[id], ...patch } }))}
            onMergeTargetChange={(id, targetId) => setMergeTargets(prev => ({ ...prev, [id]: targetId }))}
            onSave={handleWorkstreamSave}
            onWorkstreamUpdate={onWorkstreamUpdate}
            onDetach={onWorkstreamDetach}
            onMerge={onWorkstreamMerge}
          />
        </div>
      </section>

      <section className="flex min-h-0 flex-col bg-surface">
        <div className="border-b border-border px-4 py-4">
          <div className="flex items-center gap-3">
            <SpellCircle chamber="dojo" size={22} compact />
            <div>
              <h2 className="text-sm font-semibold text-slate-100">Recent Sessions</h2>
              <p className="text-xs text-muted">Ephemeral chat flow with promotion, archive, and archive recall search.</p>
            </div>
          </div>
          <div className="mt-4 flex gap-2">
            <input
              type="text"
              value={archiveQuery}
              onChange={event => setArchiveQuery(event.target.value)}
              placeholder="Search archive…"
              className="flex-1 rounded-xl border border-border bg-raised px-3 py-2 text-sm text-slate-100 outline-none placeholder:text-dim"
            />
            <button
              onClick={() => onArchiveSearch(archiveQuery)}
              className="rounded-xl border border-border px-3 py-2 text-sm text-muted transition-colors hover:text-slate-100"
            >
              Search
            </button>
          </div>
        </div>

        <div className="min-h-0 flex-1 space-y-5 overflow-y-auto px-4 py-4">
          <div>
            <div className="mb-3 flex items-center justify-between">
              <h3 className="text-xs font-semibold uppercase tracking-wider text-muted">Ephemeral and recent</h3>
              <span className="text-xs text-dim">{visibleRecentSessions.length}</span>
            </div>
            <div className="space-y-3">
              {visibleRecentSessions.map(session => (
                <article
                  key={session.id}
                  className={`rounded-2xl border p-3 ${
                    session.id === activeSessionId ? 'border-dojo/30 bg-dojo/10' : 'border-border bg-raised/70'
                  }`}
                >
                  <div className="flex items-start justify-between gap-3">
                    <button className="min-w-0 text-left" onClick={() => onSelectSession(session.id)}>
                      <h4 className="truncate text-sm font-medium text-slate-100">{session.title}</h4>
                      <p className="mt-1 text-xs text-dim">{sessionPreview(session.messages)}</p>
                    </button>
                    <span className="rounded-full border border-border px-2 py-0.5 text-[11px] font-mono text-muted">
                      {session.mode}
                    </span>
                  </div>
                  <div className="mt-3 flex gap-2">
                    <input
                      type="text"
                      value={sessionTitles[session.id] ?? session.title}
                      onChange={event => setSessionTitles(prev => ({ ...prev, [session.id]: event.target.value }))}
                      className="flex-1 rounded-lg border border-border bg-surface px-3 py-1.5 text-sm text-slate-100 outline-none"
                    />
                    <button
                      onClick={() => handleSessionRename(session.id)}
                      className="rounded-lg border border-border px-2.5 py-1 text-xs text-muted transition-colors hover:text-slate-100"
                    >
                      Rename
                    </button>
                  </div>
                  <div className="mt-3 flex flex-wrap gap-2">
                    <button
                      onClick={() => onOpenChat(session.id)}
                      className="rounded-lg border border-dojo/30 bg-dojo/20 px-2.5 py-1 text-xs text-dojo"
                    >
                      Open
                    </button>
                    {!session.primaryWorkstreamId && (
                      <button
                        onClick={() => onPromoteSession(session.id)}
                        className="rounded-lg border border-arkadas/30 bg-arkadas/10 px-2.5 py-1 text-xs text-arkadas"
                      >
                        Promote
                      </button>
                    )}
                    <button
                      onClick={() => onArchiveSession(session.id)}
                      className="rounded-lg border border-red-400/30 bg-red-400/10 px-2.5 py-1 text-xs text-red-300"
                    >
                      Archive
                    </button>
                  </div>
                  <p className="mt-2 text-xs text-dim">
                    Updated {formatRelativeSessionTime(session.updatedAt)}
                    {session.primaryWorkstreamId ? ` • UX primary ${session.primaryWorkstreamId}` : ' • Ephemeral'}
                  </p>
                </article>
              ))}
              {visibleRecentSessions.length === 0 && (
                <div className="rounded-2xl border border-dashed border-border p-4 text-sm text-dim">
                  No recent sessions in the active grey zone yet.
                </div>
              )}
            </div>
          </div>

          <div>
            <div className="mb-3 flex items-center justify-between">
              <h3 className="text-xs font-semibold uppercase tracking-wider text-muted">Archive search</h3>
              <span className="text-xs text-dim">{archiveResults.length}</span>
            </div>
            <div className="space-y-3">
              {archiveResults.map(result => (
                <article key={result.id} className="rounded-2xl border border-border bg-raised/70 p-3">
                  <div className="flex items-start justify-between gap-3">
                    <div className="min-w-0">
                      <h4 className="truncate text-sm font-medium text-slate-100">{result.title}</h4>
                      <p className="mt-1 text-xs text-muted">{result.summary || 'Archived session'}</p>
                    </div>
                    <button
                      onClick={() => onOpenChat(result.id)}
                      className="rounded-lg border border-border px-2.5 py-1 text-xs text-muted transition-colors hover:text-slate-100"
                    >
                      Open
                    </button>
                  </div>
                  <p className="mt-2 text-xs text-dim">
                    Archived {result.archivedAt ? formatRelativeSessionTime(result.archivedAt) : 'previously'} • Updated {formatRelativeSessionTime(result.updatedAt)}
                  </p>
                </article>
              ))}
              {archiveQuery && archiveResults.length === 0 && (
                <div className="rounded-2xl border border-dashed border-border p-4 text-sm text-dim">
                  No archive matches for this query.
                </div>
              )}
            </div>
          </div>
        </div>
      </section>
    </div>
  )
}

interface WorkstreamSectionProps {
  title: string
  items: Workstream[]
  activeSession: SessionRecord | null
  workstreamDrafts: Record<string, { name: string; summary: string; archiveAfterDays: string }>
  mergeTargets: Record<string, string>
  allWorkstreams: Workstream[]
  onDraftChange: (id: string, patch: Partial<{ name: string; summary: string; archiveAfterDays: string }>) => void
  onMergeTargetChange: (id: string, targetId: string) => void
  onSave: (workstream: Workstream) => Promise<void> | void
  onWorkstreamUpdate: (workstreamId: string, patch: Record<string, unknown>) => Promise<void> | void
  onDetach: (workstreamId: string, sessionId: string) => Promise<void> | void
  onMerge: (sourceId: string, targetId: string) => Promise<void> | void
}

function WorkstreamSection({
  title,
  items,
  activeSession,
  workstreamDrafts,
  mergeTargets,
  allWorkstreams,
  onDraftChange,
  onMergeTargetChange,
  onSave,
  onWorkstreamUpdate,
  onDetach,
  onMerge,
}: WorkstreamSectionProps) {
  return (
    <div>
      <div className="mb-3 flex items-center justify-between">
        <h3 className="text-xs font-semibold uppercase tracking-wider text-muted">{title}</h3>
        <span className="text-xs text-dim">{items.length}</span>
      </div>
      <div className="space-y-3">
        {items.map(workstream => {
          const draft = workstreamDrafts[workstream.id] ?? {
            name: workstream.name,
            summary: workstream.summary,
            archiveAfterDays: String(workstream.archiveAfterDays),
          }
          const detachCandidateId = activeSession?.primaryWorkstreamId === workstream.id
            ? activeSession.id
            : workstream.primarySessionId

          return (
            <article key={workstream.id} className="rounded-2xl border border-border bg-raised/70 p-3">
              <div className="mb-3 flex items-center justify-between gap-2">
                <div className="min-w-0">
                  <p className="truncate text-sm font-medium text-slate-100">{workstream.name}</p>
                  <p className="text-xs text-dim">
                    {workstream.sessionCount} session{workstream.sessionCount === 1 ? '' : 's'}
                    {workstream.pinned ? ' • pinned' : ''}
                    {workstream.status !== 'active' ? ` • ${workstream.status}` : ''}
                  </p>
                </div>
                <span className="rounded-full border border-border px-2 py-0.5 text-[11px] font-mono text-muted">
                  {workstream.id}
                </span>
              </div>

              <div className="space-y-2">
                <input
                  type="text"
                  value={draft.name}
                  onChange={event => onDraftChange(workstream.id, { name: event.target.value })}
                  className="w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm text-slate-100 outline-none"
                />
                <textarea
                  value={draft.summary}
                  onChange={event => onDraftChange(workstream.id, { summary: event.target.value })}
                  rows={3}
                  className="w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm text-slate-100 outline-none"
                />
                <div className="flex items-center gap-2">
                  <label className="text-xs text-dim">Archive after</label>
                  <input
                    type="number"
                    min={7}
                    max={365}
                    value={draft.archiveAfterDays}
                    onChange={event => onDraftChange(workstream.id, { archiveAfterDays: event.target.value })}
                    className="w-20 rounded-lg border border-border bg-surface px-2 py-1 text-sm text-slate-100 outline-none"
                  />
                  <span className="text-xs text-dim">days</span>
                </div>
              </div>

              <div className="mt-3 flex flex-wrap gap-2">
                <button
                  onClick={() => onSave(workstream)}
                  className="rounded-lg border border-border px-2.5 py-1 text-xs text-muted transition-colors hover:text-slate-100"
                >
                  Save
                </button>
                <button
                  onClick={() => onWorkstreamUpdate(workstream.id, { pinned: !workstream.pinned })}
                  className="rounded-lg border border-arkadas/30 bg-arkadas/10 px-2.5 py-1 text-xs text-arkadas"
                >
                  {workstream.pinned ? 'Unpin' : 'Pin'}
                </button>
                <button
                  onClick={() => onWorkstreamUpdate(workstream.id, { status: workstream.status === 'archived' ? 'active' : 'archived' })}
                  className="rounded-lg border border-red-400/30 bg-red-400/10 px-2.5 py-1 text-xs text-red-300"
                >
                  {workstream.status === 'archived' ? 'Restore' : 'Archive'}
                </button>
                {detachCandidateId && (
                  <button
                    onClick={() => onDetach(workstream.id, detachCandidateId)}
                    className="rounded-lg border border-amber-400/30 bg-amber-400/10 px-2.5 py-1 text-xs text-amber-300"
                  >
                    Detach session
                  </button>
                )}
              </div>

              <div className="mt-3 flex gap-2">
                <select
                  value={mergeTargets[workstream.id] ?? ''}
                  onChange={event => onMergeTargetChange(workstream.id, event.target.value)}
                  className="flex-1 rounded-lg border border-border bg-surface px-3 py-1.5 text-sm text-slate-100 outline-none"
                >
                  <option value="">Merge into…</option>
                  {allWorkstreams
                    .filter(candidate => candidate.id !== workstream.id && candidate.status === 'active')
                    .map(candidate => (
                      <option key={candidate.id} value={candidate.id}>{candidate.name}</option>
                    ))}
                </select>
                <button
                  onClick={() => {
                    const target = mergeTargets[workstream.id]
                    if (target) onMerge(workstream.id, target)
                  }}
                  disabled={!mergeTargets[workstream.id]}
                  className="rounded-lg border border-border px-2.5 py-1 text-xs text-muted transition-colors hover:text-slate-100 disabled:opacity-40"
                >
                  Merge
                </button>
              </div>

              <p className="mt-2 text-xs text-dim">
                Last active {formatRelativeSessionTime(workstream.lastActiveAt)}
                {workstream.primarySessionId ? ` • Primary session ${workstream.primarySessionId}` : ''}
              </p>
            </article>
          )
        })}
        {items.length === 0 && (
          <div className="rounded-2xl border border-dashed border-border p-4 text-sm text-dim">
            No workstreams in this band.
          </div>
        )}
      </div>
    </div>
  )
}

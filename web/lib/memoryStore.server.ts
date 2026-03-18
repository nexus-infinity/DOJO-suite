import 'server-only'

import { mkdirSync } from 'node:fs'
import { DatabaseSync } from 'node:sqlite'
import path from 'node:path'
import type {
  ArchiveSearchResult,
  MemoryStatus,
  PersonalMemoryItem,
  PersistentSession,
  PromotionCandidate,
  SessionMessage,
  SessionMode,
  SessionStatus,
  Workstream,
  WorkstreamSuggestion,
  WorkstreamStatus,
} from './memoryTypes'

const FIELD_DB_DIR = '/Users/field/◎memorycore/databases'
const MEMORY_DB_PATH = path.join(FIELD_DB_DIR, 'dojo_web_memory_v1.sqlite')
const DEFAULT_GREY_ZONE_DAYS = 30
const DEFAULT_WORKSTREAM_ARCHIVE_DAYS = 30

const STOPWORDS = new Set([
  'a', 'an', 'and', 'are', 'as', 'at', 'be', 'but', 'by', 'for', 'from', 'how',
  'i', 'if', 'in', 'into', 'is', 'it', 'its', 'of', 'on', 'or', 's', 'that',
  'the', 'their', 'them', 'there', 'this', 'to', 'was', 'we', 'what', 'when',
  'where', 'which', 'with', 'you', 'your',
])

declare global {
  // eslint-disable-next-line no-var
  var __dojoMemoryDb: DatabaseSync | undefined
}

function db() {
  if (!globalThis.__dojoMemoryDb) {
    mkdirSync(FIELD_DB_DIR, { recursive: true })
    const instance = new DatabaseSync(MEMORY_DB_PATH)
    init(instance)
    globalThis.__dojoMemoryDb = instance
  }
  return globalThis.__dojoMemoryDb
}

function init(database: DatabaseSync) {
  database.exec(`
    PRAGMA journal_mode = WAL;
    PRAGMA synchronous = NORMAL;

    CREATE TABLE IF NOT EXISTS sessions (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      mode TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'active',
      primary_workstream_id TEXT,
      messages_json TEXT NOT NULL DEFAULT '[]',
      summary TEXT NOT NULL DEFAULT '',
      include_archive INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      last_active_at TEXT NOT NULL,
      archived_at TEXT
    );

    CREATE TABLE IF NOT EXISTS workstreams (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      summary TEXT NOT NULL DEFAULT '',
      status TEXT NOT NULL DEFAULT 'active',
      pinned INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      last_active_at TEXT NOT NULL,
      archive_after_days INTEGER NOT NULL DEFAULT 30
    );

    CREATE TABLE IF NOT EXISTS workstream_links (
      workstream_id TEXT NOT NULL,
      session_id TEXT NOT NULL,
      link_score REAL NOT NULL DEFAULT 0,
      link_reason TEXT NOT NULL,
      is_manual_override INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      PRIMARY KEY (workstream_id, session_id)
    );

    CREATE TABLE IF NOT EXISTS personal_memory_items (
      id TEXT PRIMARY KEY,
      kind TEXT NOT NULL,
      content TEXT NOT NULL,
      source TEXT NOT NULL,
      confidence REAL NOT NULL DEFAULT 0,
      status TEXT NOT NULL DEFAULT 'draft',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      last_used_at TEXT
    );

    CREATE TABLE IF NOT EXISTS memory_settings (
      key TEXT PRIMARY KEY,
      value_json TEXT NOT NULL
    );
  `)

  const grey = database.prepare(`SELECT value_json FROM memory_settings WHERE key = 'grey_zone_days'`).get() as { value_json?: string } | undefined
  if (!grey) {
    database.prepare(`INSERT INTO memory_settings (key, value_json) VALUES ('grey_zone_days', ?)`)
      .run(JSON.stringify(DEFAULT_GREY_ZONE_DAYS))
  }
}

export function listSessions() {
  const sessions = db().prepare(`
    SELECT id, title, mode, status, primary_workstream_id, messages_json, summary, include_archive,
           created_at, updated_at, last_active_at, archived_at
    FROM sessions
    ORDER BY datetime(updated_at) DESC
  `).all() as unknown as SessionRow[]

  const greyDays = getGreyZoneDays()
  const now = Date.now()
  const greyCutoffMs = greyDays * 24 * 60 * 60 * 1000

  const records = sessions.map(rowToSession)
  const active = records.filter(session => session.status === 'active')
  const archive = records.filter(session => session.status === 'archived')
  const greyZone = active.filter(session => now - Date.parse(session.lastActiveAt) <= greyCutoffMs)
  const dormant = active.filter(session => now - Date.parse(session.lastActiveAt) > greyCutoffMs)

  return {
    sessions: records,
    greyZone,
    dormant,
    archive,
    greyZoneDays: greyDays,
  }
}

export function getSession(sessionId: string) {
  const row = db().prepare(`
    SELECT id, title, mode, status, primary_workstream_id, messages_json, summary, include_archive,
           created_at, updated_at, last_active_at, archived_at
    FROM sessions
    WHERE id = ?
  `).get(sessionId) as SessionRow | undefined

  return row ? rowToSession(row) : null
}

export function createSession(input: { id: string; title: string; mode: SessionMode }) {
  const now = new Date().toISOString()
  db().prepare(`
    INSERT INTO sessions (
      id, title, mode, status, primary_workstream_id, messages_json, summary, include_archive,
      created_at, updated_at, last_active_at, archived_at
    ) VALUES (?, ?, ?, 'active', NULL, '[]', '', 0, ?, ?, ?, NULL)
  `).run(input.id, input.title, input.mode, now, now, now)

  return getSession(input.id)
}

export function patchSession(input: {
  id: string
  title?: string
  mode?: SessionMode
  status?: SessionStatus
  messages?: SessionMessage[]
  summary?: string
  includeArchive?: boolean
}) {
  const current = getSession(input.id)
  if (!current) return null

  const next: PersistentSession = {
    ...current,
    title: input.title ?? current.title,
    mode: input.mode ?? current.mode,
    status: input.status ?? current.status,
    messages: input.messages ?? current.messages,
    summary: input.summary ?? current.summary,
    includeArchive: input.includeArchive ?? current.includeArchive,
    updatedAt: new Date().toISOString(),
    lastActiveAt: input.messages ? latestMessageTime(input.messages) ?? new Date().toISOString() : current.lastActiveAt,
    archivedAt: input.status === 'archived' ? new Date().toISOString() : input.status === 'active' ? null : current.archivedAt,
  }

  db().prepare(`
    UPDATE sessions
    SET title = ?, mode = ?, status = ?, messages_json = ?, summary = ?, include_archive = ?,
        updated_at = ?, last_active_at = ?, archived_at = ?
    WHERE id = ?
  `).run(
    next.title,
    next.mode,
    next.status,
    JSON.stringify(next.messages),
    next.summary,
    next.includeArchive ? 1 : 0,
    next.updatedAt,
    next.lastActiveAt,
    next.archivedAt,
    next.id
  )

  evaluateSessionMemory(next.id)
  return getSession(input.id)
}

export function listWorkstreams() {
  const workstreams = db().prepare(`
    SELECT w.id, w.name, w.summary, w.status, w.pinned, w.created_at, w.updated_at, w.last_active_at, w.archive_after_days,
           (
             SELECT session_id
             FROM workstream_links wl
             WHERE wl.workstream_id = w.id AND wl.link_score > 0
             ORDER BY wl.link_score DESC, datetime(wl.updated_at) DESC
             LIMIT 1
           ) AS primary_session_id,
           (
             SELECT COUNT(*)
             FROM workstream_links wl
             WHERE wl.workstream_id = w.id AND wl.link_score > 0
           ) AS session_count
    FROM workstreams w
    ORDER BY w.pinned DESC, datetime(w.last_active_at) DESC
  `).all() as unknown as WorkstreamRow[]

  const now = Date.now()
  const activeThisWeek: Workstream[] = []
  const greyZone: Workstream[] = []
  const dormant: Workstream[] = []

  for (const row of workstreams) {
    const item = rowToWorkstream(row)
    const age = now - Date.parse(item.lastActiveAt)
    if (item.status !== 'active') {
      dormant.push(item)
      continue
    }
    if (age <= 7 * 24 * 60 * 60 * 1000) {
      activeThisWeek.push(item)
    } else if (age <= item.archiveAfterDays * 24 * 60 * 60 * 1000) {
      greyZone.push(item)
    } else {
      dormant.push(item)
    }
  }

  return {
    workstreams: workstreams.map(rowToWorkstream),
    activeThisWeek,
    greyZone,
    dormant,
    greyZoneDays: getGreyZoneDays(),
  }
}

export function createWorkstream(input: {
  id: string
  name: string
  summary?: string
  archiveAfterDays?: number
  sessionId?: string
  linkReason?: string
  linkScore?: number
}) {
  const now = new Date().toISOString()
  db().prepare(`
    INSERT INTO workstreams (id, name, summary, status, pinned, created_at, updated_at, last_active_at, archive_after_days)
    VALUES (?, ?, ?, 'active', 0, ?, ?, ?, ?)
  `).run(
    input.id,
    input.name,
    input.summary ?? '',
    now,
    now,
    now,
    input.archiveAfterDays ?? DEFAULT_WORKSTREAM_ARCHIVE_DAYS
  )

  if (input.sessionId) {
    upsertLink(input.id, input.sessionId, input.linkScore ?? 1, input.linkReason ?? 'manual-create', true)
    recomputePrimaryWorkstream(input.sessionId)
  }

  return listWorkstreams()
}

export function patchWorkstream(input: {
  id: string
  name?: string
  summary?: string
  pinned?: boolean
  status?: WorkstreamStatus
  archiveAfterDays?: number
}) {
  const current = db().prepare(`
    SELECT id, name, summary, status, pinned, created_at, updated_at, last_active_at, archive_after_days,
           NULL AS primary_session_id, 0 AS session_count
    FROM workstreams
    WHERE id = ?
  `).get(input.id) as WorkstreamRow | undefined
  if (!current) return null

  const nextUpdatedAt = new Date().toISOString()
  db().prepare(`
    UPDATE workstreams
    SET name = ?, summary = ?, pinned = ?, status = ?, archive_after_days = ?, updated_at = ?
    WHERE id = ?
  `).run(
    input.name ?? current.name,
    input.summary ?? current.summary,
    typeof input.pinned === 'boolean' ? (input.pinned ? 1 : 0) : current.pinned,
    input.status ?? current.status,
    input.archiveAfterDays ?? current.archive_after_days,
    nextUpdatedAt,
    input.id
  )

  return listWorkstreams()
}

export function suggestWorkstreams(sessionId: string) {
  return buildSuggestions(sessionId)
}

export function mergeWorkstreams(sourceId: string, targetId: string) {
  const now = new Date().toISOString()
  const sessionRows = db().prepare(`
    SELECT session_id, link_score, link_reason, is_manual_override
    FROM workstream_links
    WHERE workstream_id = ? AND link_score > 0
  `).all(sourceId) as unknown as Array<{
    session_id: string
    link_score: number
    link_reason: string
    is_manual_override: number
  }>

  for (const row of sessionRows) {
    upsertLink(
      targetId,
      row.session_id,
      row.link_score,
      `merged-from:${sourceId}`,
      Boolean(row.is_manual_override)
    )
    recomputePrimaryWorkstream(row.session_id)
  }

  db().prepare(`
    UPDATE workstreams
    SET status = 'merged', updated_at = ?
    WHERE id = ?
  `).run(now, sourceId)

  return listWorkstreams()
}

export function detachSessionFromWorkstream(sessionId: string, workstreamId: string) {
  const now = new Date().toISOString()
  db().prepare(`
    INSERT INTO workstream_links (
      workstream_id, session_id, link_score, link_reason, is_manual_override, created_at, updated_at
    ) VALUES (?, ?, 0, 'manual_detach', 1, ?, ?)
    ON CONFLICT(workstream_id, session_id)
    DO UPDATE SET link_score = 0, link_reason = 'manual_detach', is_manual_override = 1, updated_at = excluded.updated_at
  `).run(workstreamId, sessionId, now, now)

  recomputePrimaryWorkstream(sessionId)
  return listWorkstreams()
}

export function attachSessionToWorkstream(sessionId: string, workstreamId: string) {
  upsertLink(workstreamId, sessionId, 1, 'manual_attach', true)
  recomputePrimaryWorkstream(sessionId)
  syncLinkedWorkstreamSummaries(sessionId)
  return listWorkstreams()
}

export function listPersonalMemory() {
  const items = db().prepare(`
    SELECT id, kind, content, source, confidence, status, created_at, updated_at, last_used_at
    FROM personal_memory_items
    ORDER BY CASE status WHEN 'confirmed' THEN 0 WHEN 'draft' THEN 1 ELSE 2 END, confidence DESC, datetime(updated_at) DESC
  `).all() as unknown as PersonalMemoryRow[]

  return {
    items: items.map(rowToMemory),
    greyZoneDays: getGreyZoneDays(),
  }
}

export function createPersonalMemory(input: {
  id: string
  kind: string
  content: string
  source: string
  confidence?: number
  status?: MemoryStatus
}) {
  const now = new Date().toISOString()
  db().prepare(`
    INSERT INTO personal_memory_items (
      id, kind, content, source, confidence, status, created_at, updated_at, last_used_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NULL)
  `).run(
    input.id,
    input.kind,
    input.content,
    input.source,
    input.confidence ?? 0.5,
    input.status ?? 'draft',
    now,
    now
  )
  return listPersonalMemory()
}

export function patchPersonalMemory(input: {
  id?: string
  content?: string
  status?: MemoryStatus
  greyZoneDays?: number
}) {
  if (typeof input.greyZoneDays === 'number') {
    setGreyZoneDays(input.greyZoneDays)
  }

  if (input.id) {
    const current = db().prepare(`
      SELECT id, kind, content, source, confidence, status, created_at, updated_at, last_used_at
      FROM personal_memory_items
      WHERE id = ?
    `).get(input.id) as PersonalMemoryRow | undefined

    if (current) {
      db().prepare(`
        UPDATE personal_memory_items
        SET content = ?, status = ?, updated_at = ?
        WHERE id = ?
      `).run(
        input.content ?? current.content,
        input.status ?? current.status,
        new Date().toISOString(),
        input.id
      )
    }
  }

  return listPersonalMemory()
}

export function reviewPromotion(input: { id: string; action: 'confirm' | 'demote' | 'delete' }) {
  if (input.action === 'delete') {
    db().prepare(`DELETE FROM personal_memory_items WHERE id = ?`).run(input.id)
    return listPersonalMemory()
  }

  const nextStatus: MemoryStatus = input.action === 'confirm' ? 'confirmed' : 'demoted'
  db().prepare(`
    UPDATE personal_memory_items
    SET status = ?, updated_at = ?
    WHERE id = ?
  `).run(nextStatus, new Date().toISOString(), input.id)
  return listPersonalMemory()
}

export function searchArchive(query: string) {
  const like = `%${query.trim().toLowerCase()}%`
  const rows = db().prepare(`
    SELECT id, title, summary, updated_at, archived_at, primary_workstream_id
    FROM sessions
    WHERE (status = 'archived' OR archived_at IS NOT NULL)
      AND (
        lower(title) LIKE ?
        OR lower(summary) LIKE ?
        OR lower(messages_json) LIKE ?
      )
    ORDER BY datetime(updated_at) DESC
    LIMIT 30
  `).all(like, like, like) as unknown as Array<{
    id: string
    title: string
    summary: string
    updated_at: string
    archived_at: string | null
    primary_workstream_id: string | null
  }>

  return rows.map(row => ({
    id: row.id,
    title: row.title,
    summary: row.summary,
    updatedAt: row.updated_at,
    archivedAt: row.archived_at,
    primaryWorkstreamId: row.primary_workstream_id,
  } satisfies ArchiveSearchResult))
}

export function buildRetrievalContext(sessionId: string, includeArchive: boolean) {
  const session = getSession(sessionId)
  if (!session) {
    return {
      currentSession: [],
      workstreams: [],
      confirmedMemory: [],
      draftMemory: [],
      archive: [],
    }
  }

  const linkedWorkstreams = getLinkedWorkstreams(session.id)
  const confirmedMemory = listPersonalMemory().items.filter(item => item.status === 'confirmed').slice(0, 6)
  const draftMemory = listPersonalMemory().items.filter(item => item.status === 'draft').slice(0, 4)
  const archive = includeArchive ? searchArchive(session.title || session.summary || session.messages.at(-1)?.content || '').slice(0, 5) : []

  for (const item of [...confirmedMemory, ...draftMemory]) {
    db().prepare(`
      UPDATE personal_memory_items
      SET last_used_at = ?
      WHERE id = ?
    `).run(new Date().toISOString(), item.id)
  }

  return {
    currentSession: session.messages.slice(-8),
    workstreams: linkedWorkstreams.slice(0, 3),
    confirmedMemory,
    draftMemory,
    archive,
  }
}

function evaluateSessionMemory(sessionId: string) {
  const session = getSession(sessionId)
  if (!session) return

  const suggestions = buildSuggestions(sessionId)
  const daysTouched = uniqueDayCount(session.messages)
  const qualifiesForPromotion = session.messages.length >= 6 || daysTouched >= 2

  if (suggestions.length > 0) {
    const top = suggestions[0]
    const second = suggestions[1]
    const strong = top.score >= 0.24
    const ambiguous = second ? Math.abs(top.score - second.score) < 0.08 : false

    if (strong && !ambiguous) {
      upsertLink(top.workstreamId, sessionId, top.score, top.reason, false)
      recomputePrimaryWorkstream(sessionId)
    }
  }

  if (qualifiesForPromotion && !hasPositiveLink(sessionId)) {
    const workstreamId = `ws-${session.id}`
    createWorkstream({
      id: workstreamId,
      name: deriveWorkstreamName(session),
      summary: summarizeSession(session),
      sessionId,
      linkReason: 'promoted-from-session',
      linkScore: 0.6,
    })
  } else if (qualifiesForPromotion) {
    syncLinkedWorkstreamSummaries(sessionId)
  }

  inferDraftMemory()
}

function inferDraftMemory() {
  const sessions = listSessions().sessions.filter(session => session.messages.length > 0)
  const candidateCounts = new Map<string, { count: number; sourceSessions: Set<string> }>()

  for (const session of sessions) {
    const candidates = extractMemoryCandidates(session)
    for (const candidate of candidates) {
      const entry = candidateCounts.get(candidate) ?? { count: 0, sourceSessions: new Set<string>() }
      if (!entry.sourceSessions.has(session.id)) {
        entry.count += 1
        entry.sourceSessions.add(session.id)
      }
      candidateCounts.set(candidate, entry)
    }
  }

  for (const [candidate, entry] of candidateCounts.entries()) {
    if (entry.count < 3) continue
    const existing = db().prepare(`
      SELECT id FROM personal_memory_items WHERE content = ?
    `).get(candidate) as { id?: string } | undefined
    if (existing?.id) continue

    createPersonalMemory({
      id: `mem-${slug(candidate)}`,
      kind: 'inferred-pattern',
      content: candidate,
      source: `repeated-across-${entry.count}-sessions`,
      confidence: Math.min(0.95, 0.45 + entry.count * 0.1),
      status: 'draft',
    })
  }
}

function buildSuggestions(sessionId: string) {
  const session = getSession(sessionId)
  if (!session) return []

  const sessionTokens = tokensForSession(session)
  if (sessionTokens.length === 0) return []

  const workstreams = listWorkstreams().workstreams.filter(item => item.status === 'active')
  const suggestions: WorkstreamSuggestion[] = []

  for (const workstream of workstreams) {
    const existingLink = db().prepare(`
      SELECT link_score, link_reason, is_manual_override
      FROM workstream_links
      WHERE workstream_id = ? AND session_id = ?
    `).get(workstream.id, sessionId) as {
      link_score?: number
      link_reason?: string
      is_manual_override?: number
    } | undefined

    if (existingLink?.is_manual_override && (existingLink.link_score ?? 0) <= 0) {
      continue
    }

    const workstreamTokens = tokensForWorkstream(workstream.id, workstream)
    const score = overlapScore(sessionTokens, workstreamTokens)
    if (score <= 0.12) continue

    suggestions.push({
      workstreamId: workstream.id,
      score,
      reason: `${Math.round(score * 100)}% token overlap with ${workstream.name}`,
      isAmbiguous: false,
    })
  }

  suggestions.sort((a, b) => b.score - a.score)
  if (suggestions.length > 1 && Math.abs(suggestions[0].score - suggestions[1].score) < 0.08) {
    suggestions[0].isAmbiguous = true
    suggestions[1].isAmbiguous = true
  }

  return suggestions.slice(0, 5)
}

function getLinkedWorkstreams(sessionId: string) {
  const rows = db().prepare(`
    SELECT w.id, w.name, w.summary, w.status, w.pinned, w.created_at, w.updated_at, w.last_active_at, w.archive_after_days,
           (
             SELECT session_id
             FROM workstream_links nested
             WHERE nested.workstream_id = w.id AND nested.link_score > 0
             ORDER BY nested.link_score DESC, datetime(nested.updated_at) DESC
             LIMIT 1
           ) AS primary_session_id,
           (
             SELECT COUNT(*)
             FROM workstream_links nested
             WHERE nested.workstream_id = w.id AND nested.link_score > 0
           ) AS session_count
    FROM workstreams w
    JOIN workstream_links wl ON wl.workstream_id = w.id
    WHERE wl.session_id = ? AND wl.link_score > 0
    ORDER BY wl.link_score DESC, datetime(w.last_active_at) DESC
  `).all(sessionId) as unknown as WorkstreamRow[]

  return rows.map(rowToWorkstream)
}

function syncLinkedWorkstreamSummaries(sessionId: string) {
  const session = getSession(sessionId)
  if (!session) return
  const linked = getLinkedWorkstreams(sessionId)
  const now = new Date().toISOString()
  for (const workstream of linked) {
    db().prepare(`
      UPDATE workstreams
      SET summary = ?, updated_at = ?, last_active_at = ?
      WHERE id = ?
    `).run(
      summarizeLinkedWorkstream(workstream.id, workstream.name),
      now,
      session.lastActiveAt,
      workstream.id
    )
  }
}

function hasPositiveLink(sessionId: string) {
  const row = db().prepare(`
    SELECT 1
    FROM workstream_links
    WHERE session_id = ? AND link_score > 0
    LIMIT 1
  `).get(sessionId) as { 1?: number } | undefined
  return Boolean(row)
}

function upsertLink(workstreamId: string, sessionId: string, score: number, reason: string, isManualOverride: boolean) {
  const now = new Date().toISOString()
  db().prepare(`
    INSERT INTO workstream_links (
      workstream_id, session_id, link_score, link_reason, is_manual_override, created_at, updated_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?)
    ON CONFLICT(workstream_id, session_id)
    DO UPDATE SET
      link_score = excluded.link_score,
      link_reason = excluded.link_reason,
      is_manual_override = excluded.is_manual_override,
      updated_at = excluded.updated_at
  `).run(workstreamId, sessionId, score, reason, isManualOverride ? 1 : 0, now, now)
}

function recomputePrimaryWorkstream(sessionId: string) {
  const row = db().prepare(`
    SELECT workstream_id
    FROM workstream_links
    WHERE session_id = ? AND link_score > 0
    ORDER BY is_manual_override DESC, link_score DESC, datetime(updated_at) DESC
    LIMIT 1
  `).get(sessionId) as { workstream_id?: string } | undefined

  db().prepare(`
    UPDATE sessions
    SET primary_workstream_id = ?, updated_at = ?
    WHERE id = ?
  `).run(row?.workstream_id ?? null, new Date().toISOString(), sessionId)
}

function setGreyZoneDays(days: number) {
  db().prepare(`
    INSERT INTO memory_settings (key, value_json)
    VALUES ('grey_zone_days', ?)
    ON CONFLICT(key) DO UPDATE SET value_json = excluded.value_json
  `).run(JSON.stringify(Math.max(7, Math.min(180, Math.round(days)))))
}

function getGreyZoneDays() {
  const row = db().prepare(`
    SELECT value_json
    FROM memory_settings
    WHERE key = 'grey_zone_days'
  `).get() as { value_json?: string } | undefined

  const value = Number(row?.value_json ? JSON.parse(row.value_json) : DEFAULT_GREY_ZONE_DAYS)
  return Number.isFinite(value) ? value : DEFAULT_GREY_ZONE_DAYS
}

function extractMemoryCandidates(session: PersistentSession) {
  const candidates = new Set<string>()
  for (const message of session.messages) {
    if (message.role !== 'user') continue
    const normalized = normalizeWhitespace(message.content)
    if (normalized.length < 24 || normalized.length > 140) continue
    candidates.add(normalized)
  }
  return [...candidates]
}

function deriveWorkstreamName(session: PersistentSession) {
  if (session.title && session.title !== 'New session') return session.title
  const firstUser = session.messages.find(message => message.role === 'user' && message.content.trim())
  return firstUser ? normalizeWhitespace(firstUser.content).slice(0, 60) : 'Untitled workstream'
}

function summarizeSession(session: PersistentSession) {
  const preview = session.messages
    .filter(message => message.role !== 'tool')
    .slice(-3)
    .map(message => normalizeWhitespace(message.content))
    .join(' ')
    .trim()
  return preview ? preview.slice(0, 220) : ''
}

function summarizeLinkedWorkstream(workstreamId: string, name: string) {
  const rows = db().prepare(`
    SELECT s.summary, s.title
    FROM sessions s
    JOIN workstream_links wl ON wl.session_id = s.id
    WHERE wl.workstream_id = ? AND wl.link_score > 0
    ORDER BY datetime(s.updated_at) DESC
    LIMIT 3
  `).all(workstreamId) as unknown as Array<{ summary: string; title: string }>

  const joined = rows.map(row => row.summary || row.title).filter(Boolean).join(' ').trim()
  return joined ? joined.slice(0, 220) : name
}

function tokensForSession(session: PersistentSession) {
  return tokenize([
    session.title,
    session.summary,
    ...session.messages.slice(-10).map(message => message.content),
  ].join(' '))
}

function tokensForWorkstream(workstreamId: string, workstream: Workstream) {
  const rows = db().prepare(`
    SELECT s.title, s.summary, s.messages_json
    FROM sessions s
    JOIN workstream_links wl ON wl.session_id = s.id
    WHERE wl.workstream_id = ? AND wl.link_score > 0
    ORDER BY datetime(s.updated_at) DESC
    LIMIT 8
  `).all(workstreamId) as unknown as Array<{ title: string; summary: string; messages_json: string }>

  const text = [
    workstream.name,
    workstream.summary,
    ...rows.map(row => `${row.title} ${row.summary} ${row.messages_json}`),
  ].join(' ')

  return tokenize(text)
}

function tokenize(text: string) {
  const parts = text
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, ' ')
    .split(/\s+/)
    .filter(part => part.length >= 3 && !STOPWORDS.has(part))

  return [...new Set(parts)]
}

function overlapScore(a: string[], b: string[]) {
  if (a.length === 0 || b.length === 0) return 0
  const aSet = new Set(a)
  const bSet = new Set(b)
  let intersection = 0
  for (const token of aSet) {
    if (bSet.has(token)) intersection += 1
  }
  const union = new Set([...aSet, ...bSet]).size
  return union === 0 ? 0 : intersection / union
}

function normalizeWhitespace(value: string) {
  return value.replace(/\s+/g, ' ').trim()
}

function uniqueDayCount(messages: SessionMessage[]) {
  return new Set(messages.map(message => message.timestamp.slice(0, 10))).size
}

function latestMessageTime(messages: SessionMessage[]) {
  return messages.at(-1)?.timestamp ?? null
}

function slug(value: string) {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '').slice(0, 48)
}

interface SessionRow {
  id: string
  title: string
  mode: SessionMode
  status: SessionStatus
  primary_workstream_id: string | null
  messages_json: string
  summary: string
  include_archive: number
  created_at: string
  updated_at: string
  last_active_at: string
  archived_at: string | null
}

interface WorkstreamRow {
  id: string
  name: string
  summary: string
  status: WorkstreamStatus
  pinned: number
  created_at: string
  updated_at: string
  last_active_at: string
  archive_after_days: number
  primary_session_id: string | null
  session_count: number
}

interface PersonalMemoryRow {
  id: string
  kind: string
  content: string
  source: string
  confidence: number
  status: MemoryStatus
  created_at: string
  updated_at: string
  last_used_at: string | null
}

function rowToSession(row: SessionRow): PersistentSession {
  return {
    id: row.id,
    title: row.title,
    mode: row.mode,
    status: row.status,
    primaryWorkstreamId: row.primary_workstream_id,
    messages: JSON.parse(row.messages_json) as SessionMessage[],
    summary: row.summary,
    includeArchive: Boolean(row.include_archive),
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    lastActiveAt: row.last_active_at,
    archivedAt: row.archived_at,
  }
}

function rowToWorkstream(row: WorkstreamRow): Workstream {
  return {
    id: row.id,
    name: row.name,
    summary: row.summary,
    status: row.status,
    pinned: Boolean(row.pinned),
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    lastActiveAt: row.last_active_at,
    archiveAfterDays: row.archive_after_days,
    primarySessionId: row.primary_session_id,
    sessionCount: row.session_count,
  }
}

function rowToMemory(row: PersonalMemoryRow): PersonalMemoryItem {
  return {
    id: row.id,
    kind: row.kind,
    content: row.content,
    source: row.source,
    confidence: row.confidence,
    status: row.status,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    lastUsedAt: row.last_used_at,
  }
}

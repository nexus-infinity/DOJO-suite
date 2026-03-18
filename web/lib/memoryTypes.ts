export type SessionMode = 'chat' | 'code' | 'collab'
export type SessionRole = 'user' | 'assistant' | 'tool'
export type SessionStatus = 'active' | 'archived'
export type WorkstreamStatus = 'active' | 'archived' | 'merged'
export type MemoryStatus = 'draft' | 'confirmed' | 'demoted'

export interface SessionMessage {
  id: string
  role: SessionRole
  content: string
  toolName?: string
  timestamp: string
}

export interface PersistentSession {
  id: string
  title: string
  mode: SessionMode
  status: SessionStatus
  primaryWorkstreamId: string | null
  messages: SessionMessage[]
  summary: string
  includeArchive: boolean
  createdAt: string
  updatedAt: string
  lastActiveAt: string
  archivedAt: string | null
}

export interface Workstream {
  id: string
  name: string
  summary: string
  status: WorkstreamStatus
  pinned: boolean
  createdAt: string
  updatedAt: string
  lastActiveAt: string
  archiveAfterDays: number
  primarySessionId: string | null
  sessionCount: number
}

export interface WorkstreamLink {
  workstreamId: string
  sessionId: string
  linkScore: number
  linkReason: string
  isManualOverride: boolean
  createdAt: string
  updatedAt: string
}

export interface PersonalMemoryItem {
  id: string
  kind: string
  content: string
  source: string
  confidence: number
  status: MemoryStatus
  createdAt: string
  updatedAt: string
  lastUsedAt: string | null
}

export interface PromotionCandidate {
  id: string
  content: string
  source: string
  confidence: number
  status: MemoryStatus
}

export interface ArchiveSearchResult {
  id: string
  title: string
  summary: string
  updatedAt: string
  archivedAt: string | null
  primaryWorkstreamId: string | null
}

export interface WorkstreamSuggestion {
  workstreamId: string
  score: number
  reason: string
  isAmbiguous: boolean
}

'use client'

export type {
  PersonalMemoryItem,
  PersistentSession as SessionRecord,
  SessionMessage,
  SessionMode,
  Workstream,
  WorkstreamSuggestion,
} from './memoryTypes'

import type { SessionMessage } from './memoryTypes'

export function createSessionId() {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID()
  }
  return `session-${Date.now()}`
}

export function inferSessionTitle(messages: SessionMessage[]): string {
  const firstUser = messages.find(message => message.role === 'user' && message.content.trim())
  if (!firstUser) return 'New session'
  return truncate(firstUser.content.replace(/\s+/g, ' ').trim(), 42)
}

export function sessionPreview(messages: SessionMessage[]): string {
  const lastMeaningful = [...messages].reverse().find(message => message.content.trim())
  if (!lastMeaningful) return 'No messages yet'
  return truncate(lastMeaningful.content.replace(/\s+/g, ' ').trim(), 96)
}

export function formatRelativeSessionTime(iso: string): string {
  const value = new Date(iso).getTime()
  if (Number.isNaN(value)) return 'Unknown'

  const deltaMs = Date.now() - value
  const minute = 60_000
  const hour = 60 * minute
  const day = 24 * hour

  if (deltaMs < minute) return 'Just now'
  if (deltaMs < hour) return `${Math.floor(deltaMs / minute)}m ago`
  if (deltaMs < day) return `${Math.floor(deltaMs / hour)}h ago`
  if (deltaMs < 7 * day) return `${Math.floor(deltaMs / day)}d ago`

  return new Date(iso).toLocaleDateString()
}

function truncate(value: string, max: number) {
  return value.length <= max ? value : `${value.slice(0, max - 1)}…`
}

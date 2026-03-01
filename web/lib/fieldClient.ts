// FIELD chamber HTTP client — server-side only
// All calls to Mac Studio chambers go through Next.js API routes.
// Never call chamber endpoints directly from the browser.

import { chamberUrl, type ChamberKey } from './chambers'

export interface ChamberHealthResponse {
  status: 'alive' | 'degraded' | 'offline'
  chamber: string
  frequency: number
  port: number
  stage?: string
  uptime?: number
  error?: string
}

export async function fetchChamberHealth(key: ChamberKey): Promise<ChamberHealthResponse> {
  try {
    const url = `${chamberUrl(key)}/health`
    const res = await fetch(url, { next: { revalidate: 10 } })
    if (!res.ok) throw new Error(`HTTP ${res.status}`)
    return await res.json()
  } catch (err) {
    return {
      status: 'offline',
      chamber: key,
      frequency: 0,
      port: 0,
      error: err instanceof Error ? err.message : 'unreachable',
    }
  }
}

export async function postToDojoChat(message: string, history: { role: string; content: string }[]) {
  const url = `${chamberUrl('dojo')}/chat`
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ message, history }),
  })
  if (!res.ok) throw new Error(`DOJO chat error: HTTP ${res.status}`)
  return res.json()
}

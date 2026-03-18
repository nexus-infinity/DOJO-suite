// ◼︎ DOJO Web — /api/health
// Aggregates health status from all FIELD chambers.
// Called by the sidebar to show live chamber state.

import { readFile } from 'node:fs/promises'
import path from 'node:path'
import { type NextRequest, NextResponse } from 'next/server'
import { fetchChamberHealth } from '@/lib/fieldClient'
import { CHAMBERS } from '@/lib/chambers'

export const dynamic = 'force-dynamic'

export async function GET(_req: NextRequest) {
  const chamberKeys = Object.keys(CHAMBERS) as (keyof typeof CHAMBERS)[]

  const results = await Promise.allSettled(
    chamberKeys.map(key => fetchChamberHealth(key))
  )

  const health: Record<string, unknown> = {}
  const scores: number[] = []
  results.forEach((r, i) => {
    const key = chamberKeys[i]
    if (r.status === 'fulfilled') {
      const normalized = normalizeChamberHealth(key, { ...r.value })
      health[key] = normalized
      scores.push(normalized.score)
      return
    }

    health[key] = normalizeChamberHealth(key, { status: 'offline', error: 'unreachable' })
    scores.push(0)
  })

  const bear = await readBearState()
  const derivedBear = scores.length ? scores.reduce((sum, value) => sum + value, 0) / scores.length : 0

  return NextResponse.json({
    timestamp: new Date().toISOString(),
    chambers: health,
    alive: Object.values(health).filter(value => {
      const status = (value as { normalizedStatus?: string }).normalizedStatus
      return status === 'alive'
    }).length,
    total: chamberKeys.length,
    bear: bear ?? {
      score: Number(derivedBear.toFixed(4)),
      label: derivedBear >= 0.9 ? 'strong' : derivedBear >= 0.75 ? 'stable' : derivedBear >= 0.5 ? 'degraded' : 'critical',
      source: 'derived-from-live-chamber-health',
    },
  })
}

function normalizeChamberHealth(key: keyof typeof CHAMBERS, value: Record<string, unknown>) {
  const status = String(value.status ?? 'offline').toLowerCase()
  const normalizedStatus =
    status === 'healthy' || status === 'stable' || status === 'alive'
      ? 'alive'
      : status === 'degraded'
      ? 'degraded'
      : 'offline'

  const score =
    typeof value.coherence === 'number'
      ? value.coherence
      : normalizedStatus === 'alive'
      ? 1
      : normalizedStatus === 'degraded'
      ? 0.5
      : 0

  return {
    chamber: key,
    port: CHAMBERS[key].port,
    frequency: CHAMBERS[key].freq,
    ...value,
    normalizedStatus,
    score,
  }
}

async function readBearState() {
  const candidates = [
    '/Users/field/dojo_dev_state.json',
    path.resolve(process.cwd(), '..', '..', '..', 'dojo_dev_state.json'),
  ]

  for (const candidate of candidates) {
    try {
      const raw = await readFile(candidate, 'utf8')
      const parsed = JSON.parse(raw)
      const homeostasis = parsed?.homeostasis_last_check
      if (!homeostasis || typeof homeostasis.score !== 'number') continue

      return {
        score: homeostasis.score,
        label: typeof homeostasis.label === 'string' ? homeostasis.label : 'unknown',
        source: 'dojo_dev_state.homeostasis_last_check',
        timestamp: homeostasis.timestamp ?? null,
        recommendedAction: homeostasis.recommended_action ?? null,
      }
    } catch {
      continue
    }
  }

  return null
}

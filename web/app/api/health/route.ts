// ◼︎ DOJO Web — /api/health
// Aggregates health status from all FIELD chambers.
// Called by the sidebar to show live chamber state.

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
  results.forEach((r, i) => {
    const key = chamberKeys[i]
    health[key] = r.status === 'fulfilled' ? r.value : { status: 'offline', error: 'unreachable' }
  })

  return NextResponse.json({
    timestamp: new Date().toISOString(),
    chambers: health,
    alive: results.filter(r => r.status === 'fulfilled' && (r.value as any).status === 'alive').length,
    total: chamberKeys.length,
  })
}

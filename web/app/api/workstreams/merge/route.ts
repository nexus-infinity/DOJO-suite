import { NextRequest, NextResponse } from 'next/server'
import { mergeWorkstreams } from '@/lib/memoryStore.server'

export const dynamic = 'force-dynamic'

export async function POST(req: NextRequest) {
  const body = await req.json()
  if (typeof body.sourceId !== 'string' || typeof body.targetId !== 'string') {
    return NextResponse.json({ error: 'sourceId and targetId required' }, { status: 400 })
  }

  return NextResponse.json(mergeWorkstreams(body.sourceId, body.targetId))
}

import { NextRequest, NextResponse } from 'next/server'
import { attachSessionToWorkstream } from '@/lib/memoryStore.server'

export const dynamic = 'force-dynamic'

export async function POST(req: NextRequest) {
  const body = await req.json()
  if (typeof body.sessionId !== 'string' || typeof body.workstreamId !== 'string') {
    return NextResponse.json({ error: 'sessionId and workstreamId required' }, { status: 400 })
  }

  return NextResponse.json(attachSessionToWorkstream(body.sessionId, body.workstreamId))
}

import { NextRequest, NextResponse } from 'next/server'
import { suggestWorkstreams } from '@/lib/memoryStore.server'

export const dynamic = 'force-dynamic'

export async function POST(req: NextRequest) {
  const body = await req.json()
  if (typeof body.sessionId !== 'string') {
    return NextResponse.json({ error: 'sessionId required' }, { status: 400 })
  }

  return NextResponse.json({ suggestions: suggestWorkstreams(body.sessionId) })
}

import { NextRequest, NextResponse } from 'next/server'
import { createSession, listSessions, patchSession } from '@/lib/memoryStore.server'
import type { SessionMessage, SessionMode, SessionStatus } from '@/lib/memoryTypes'

export const dynamic = 'force-dynamic'

export async function GET() {
  return NextResponse.json(listSessions())
}

export async function POST(req: NextRequest) {
  const body = await req.json()
  const session = createSession({
    id: body.id,
    title: typeof body.title === 'string' ? body.title : 'New session',
    mode: (body.mode as SessionMode | undefined) ?? 'chat',
  })

  return NextResponse.json({ session, ...listSessions() })
}

export async function PATCH(req: NextRequest) {
  const body = await req.json()
  const session = patchSession({
    id: body.id,
    title: typeof body.title === 'string' ? body.title : undefined,
    mode: body.mode as SessionMode | undefined,
    status: body.status as SessionStatus | undefined,
    messages: Array.isArray(body.messages) ? (body.messages as SessionMessage[]) : undefined,
    summary: typeof body.summary === 'string' ? body.summary : undefined,
    includeArchive: typeof body.includeArchive === 'boolean' ? body.includeArchive : undefined,
  })

  if (!session) {
    return NextResponse.json({ error: 'Session not found' }, { status: 404 })
  }

  return NextResponse.json({ session, ...listSessions() })
}

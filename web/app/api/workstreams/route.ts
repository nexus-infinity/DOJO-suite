import { NextRequest, NextResponse } from 'next/server'
import { createWorkstream, listWorkstreams, patchWorkstream } from '@/lib/memoryStore.server'

export const dynamic = 'force-dynamic'

export async function GET() {
  return NextResponse.json(listWorkstreams())
}

export async function POST(req: NextRequest) {
  const body = await req.json()
  return NextResponse.json(createWorkstream({
    id: body.id,
    name: body.name,
    summary: typeof body.summary === 'string' ? body.summary : undefined,
    archiveAfterDays: typeof body.archiveAfterDays === 'number' ? body.archiveAfterDays : undefined,
    sessionId: typeof body.sessionId === 'string' ? body.sessionId : undefined,
    linkReason: typeof body.linkReason === 'string' ? body.linkReason : undefined,
    linkScore: typeof body.linkScore === 'number' ? body.linkScore : undefined,
  }))
}

export async function PATCH(req: NextRequest) {
  const body = await req.json()
  const result = patchWorkstream({
    id: body.id,
    name: typeof body.name === 'string' ? body.name : undefined,
    summary: typeof body.summary === 'string' ? body.summary : undefined,
    pinned: typeof body.pinned === 'boolean' ? body.pinned : undefined,
    status: typeof body.status === 'string' ? body.status : undefined,
    archiveAfterDays: typeof body.archiveAfterDays === 'number' ? body.archiveAfterDays : undefined,
  })

  if (!result) {
    return NextResponse.json({ error: 'Workstream not found' }, { status: 404 })
  }

  return NextResponse.json(result)
}

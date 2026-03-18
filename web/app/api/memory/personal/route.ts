import { NextRequest, NextResponse } from 'next/server'
import { createPersonalMemory, listPersonalMemory, patchPersonalMemory } from '@/lib/memoryStore.server'
import type { MemoryStatus } from '@/lib/memoryTypes'

export const dynamic = 'force-dynamic'

export async function GET() {
  return NextResponse.json(listPersonalMemory())
}

export async function POST(req: NextRequest) {
  const body = await req.json()
  return NextResponse.json(createPersonalMemory({
    id: body.id,
    kind: typeof body.kind === 'string' ? body.kind : 'manual',
    content: body.content,
    source: typeof body.source === 'string' ? body.source : 'manual',
    confidence: typeof body.confidence === 'number' ? body.confidence : undefined,
    status: body.status as MemoryStatus | undefined,
  }))
}

export async function PATCH(req: NextRequest) {
  const body = await req.json()
  return NextResponse.json(patchPersonalMemory({
    id: typeof body.id === 'string' ? body.id : undefined,
    content: typeof body.content === 'string' ? body.content : undefined,
    status: body.status as MemoryStatus | undefined,
    greyZoneDays: typeof body.greyZoneDays === 'number' ? body.greyZoneDays : undefined,
  }))
}

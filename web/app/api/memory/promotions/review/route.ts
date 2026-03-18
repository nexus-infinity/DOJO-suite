import { NextRequest, NextResponse } from 'next/server'
import { reviewPromotion } from '@/lib/memoryStore.server'

export const dynamic = 'force-dynamic'

export async function POST(req: NextRequest) {
  const body = await req.json()
  if (typeof body.id !== 'string' || !['confirm', 'demote', 'delete'].includes(body.action)) {
    return NextResponse.json({ error: 'id and valid action required' }, { status: 400 })
  }

  return NextResponse.json(reviewPromotion({
    id: body.id,
    action: body.action,
  }))
}

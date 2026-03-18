import { NextRequest, NextResponse } from 'next/server'
import { searchArchive } from '@/lib/memoryStore.server'

export const dynamic = 'force-dynamic'

export async function GET(req: NextRequest) {
  const query = req.nextUrl.searchParams.get('q')?.trim() ?? ''
  if (!query) return NextResponse.json({ results: [] })
  return NextResponse.json({ results: searchArchive(query) })
}

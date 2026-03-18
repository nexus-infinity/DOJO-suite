import { NextRequest, NextResponse } from 'next/server'
import { getNaimaTrainingStatus, summarizeTrainingStatus } from '@/lib/huggingfaceStatus.server'

export const dynamic = 'force-dynamic'
export const runtime = 'nodejs'

export async function GET(req: NextRequest) {
  try {
    const jobId = req.nextUrl.searchParams.get('jobId')?.trim() || undefined
    const status = await getNaimaTrainingStatus(jobId)
    return NextResponse.json({
      ok: true,
      status,
      summary: summarizeTrainingStatus(status),
    })
  } catch (error) {
    return NextResponse.json({
      ok: false,
      error: error instanceof Error ? error.message : 'Unknown Hugging Face status error',
    }, { status: 500 })
  }
}

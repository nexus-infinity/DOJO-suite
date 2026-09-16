import { NextResponse } from 'next/server'
import { getAnzPilotSnapshot, buildInstitutionMatrix, ESCALATION_MEANINGS } from '@/lib/bankResponseMapper'

/**
 * GET /api/comms/bank-patterns
 * Bank Response Pattern Mapper — Comms surface.
 * Confidential pattern detail lives in ▲ATLAS; this returns operational snapshot only.
 */
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const institution = (searchParams.get('institution') ?? 'ANZ').toUpperCase()

  if (institution === 'ANZ') {
    const anz = getAnzPilotSnapshot()
    return NextResponse.json({
      module: 'bank_response_pattern_mapper',
      version: '0.1.0',
      institution: 'ANZ',
      phase: 1,
      snapshot: anz,
      escalationMeanings: ESCALATION_MEANINGS,
      matrix: buildInstitutionMatrix([]),
      invariant: 'Draft only after pattern map. No isolated bank letters.',
    })
  }

  return NextResponse.json(
    {
      module: 'bank_response_pattern_mapper',
      institution,
      status: 'queued',
      hold_reason: 'phase_1_anz_must_prove_first',
      message: `${institution} is registered but not yet in active pilot.`,
    },
    { status: 200 },
  )
}

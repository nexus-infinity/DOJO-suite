import { createHash } from 'node:crypto'

export const WORKSTREAM_AUTHORITY_PROOF_SCHEMA = 'WORKSTREAM_AUTHORITY_PROOF_V0'

export type WorkstreamAuthorityAction =
  | 'create'
  | 'link'
  | 'promote'
  | 'route'
  | 'rank'
  | 'alter'

export interface WorkstreamAuthorityCandidate {
  action: WorkstreamAuthorityAction
  sessionId: string
  workstreamId?: string
  correlationId: string
  content: string
  source: 'assistant' | 'recommendation' | 'inferred-link' | 'legacy'
}

export interface WorkstreamAuthorityProof {
  schemaId: typeof WORKSTREAM_AUTHORITY_PROOF_SCHEMA
  receiptId: string
  correlationId: string
  candidateDigest: string
  issuer: string
  expiresAt: string
}

export interface WorkstreamAuthorityVerifier {
  verify(proof: WorkstreamAuthorityProof): boolean
}

export interface WorkstreamAuthorityDecision {
  admitted: boolean
  reason:
    | 'PASS.CorrelatedDeterministicProof'
    | 'HOLD.AbsentProof'
    | 'HOLD.InvalidProof'
    | 'HOLD.UncorrelatedProof'
    | 'HOLD.ExpiredProof'
}

export function digestWorkstreamCandidate(candidate: WorkstreamAuthorityCandidate) {
  return createHash('sha256')
    .update(JSON.stringify({
      action: candidate.action,
      sessionId: candidate.sessionId,
      workstreamId: candidate.workstreamId ?? null,
      correlationId: candidate.correlationId,
      content: candidate.content,
      source: candidate.source,
    }))
    .digest('hex')
}

export function admitWorkstreamAuthority(
  candidate: WorkstreamAuthorityCandidate,
  proof: WorkstreamAuthorityProof | null | undefined,
  verifier: WorkstreamAuthorityVerifier,
  now = new Date(),
): WorkstreamAuthorityDecision {
  if (!proof) return { admitted: false, reason: 'HOLD.AbsentProof' }
  if (
    proof.schemaId !== WORKSTREAM_AUTHORITY_PROOF_SCHEMA
    || !proof.receiptId
    || !proof.issuer
    || !verifier.verify(proof)
  ) {
    return { admitted: false, reason: 'HOLD.InvalidProof' }
  }
  if (
    proof.correlationId !== candidate.correlationId
    || proof.candidateDigest !== digestWorkstreamCandidate(candidate)
  ) {
    return { admitted: false, reason: 'HOLD.UncorrelatedProof' }
  }
  if (!Number.isFinite(Date.parse(proof.expiresAt)) || Date.parse(proof.expiresAt) <= now.getTime()) {
    return { admitted: false, reason: 'HOLD.ExpiredProof' }
  }
  return { admitted: true, reason: 'PASS.CorrelatedDeterministicProof' }
}

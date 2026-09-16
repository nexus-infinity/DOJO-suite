import assert from 'node:assert/strict'
import {
  WORKSTREAM_AUTHORITY_PROOF_SCHEMA,
  admitWorkstreamAuthority,
  digestWorkstreamCandidate,
  type WorkstreamAuthorityCandidate,
  type WorkstreamAuthorityProof,
} from '../lib/workstreamAuthority'

const now = new Date('2026-07-25T10:30:00.000Z')
const candidate: WorkstreamAuthorityCandidate = {
  action: 'link',
  sessionId: 'session-fixture',
  workstreamId: 'workstream-fixture',
  correlationId: 'correlation-fixture',
  content: 'assistant recommendation',
  source: 'assistant',
}
const validProof: WorkstreamAuthorityProof = {
  schemaId: WORKSTREAM_AUTHORITY_PROOF_SCHEMA,
  receiptId: 'receipt-fixture',
  correlationId: candidate.correlationId,
  candidateDigest: digestWorkstreamCandidate(candidate),
  issuer: 'Kings-Chamber.fixture',
  expiresAt: '2026-07-25T10:35:00.000Z',
}
const verifier = { verify: (proof: WorkstreamAuthorityProof) => proof.receiptId === 'receipt-fixture' }

const cases = {
  absent: admitWorkstreamAuthority(candidate, null, verifier, now),
  forged: admitWorkstreamAuthority(candidate, { ...validProof, receiptId: 'forged' }, verifier, now),
  uncorrelated: admitWorkstreamAuthority(candidate, { ...validProof, correlationId: 'other' }, verifier, now),
  presentationOnly: admitWorkstreamAuthority({ ...candidate, source: 'assistant' }, null, verifier, now),
  recommendationOnly: admitWorkstreamAuthority({ ...candidate, source: 'recommendation' }, null, verifier, now),
  inferredLink: admitWorkstreamAuthority({ ...candidate, source: 'inferred-link' }, null, verifier, now),
  legacy: admitWorkstreamAuthority({ ...candidate, source: 'legacy' }, null, verifier, now),
  exactCorrelatedProof: admitWorkstreamAuthority(candidate, validProof, verifier, now),
}

for (const [name, decision] of Object.entries(cases)) {
  assert.equal(decision.admitted, name === 'exactCorrelatedProof', `${name} admission mismatch`)
}

console.log(JSON.stringify({ fixture: 'WEB_ASSISTANT_CONTENT_WORKSTREAM_STATE_BOUNDARY_V0', cases }, null, 2))

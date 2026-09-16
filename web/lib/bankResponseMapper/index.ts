/**
 * Bank Response Pattern Mapper — Comms consumer API
 *
 * Pattern store (confidential): ▲ATLAS ▲bank_response_patterns
 * Outbound still flows through commsGovernance (Render → Authorize → Execute).
 */

export * from './types'
export * from './matrix'
export * from './escalation'

import {
  FIELD_ANZ_LINE_REF,
  ATLAS_PATTERN_STORE,
  type InstitutionMatrixRow,
  type EscalationIssue,
} from './types'

/** Phase 1 pilot snapshot — static until pulse intake begins */
export interface AnzPilotSnapshot {
  canonicalRef: typeof FIELD_ANZ_LINE_REF
  institution: 'ANZ'
  status: 'mapped_ready_for_dojo_draft'
  patternStore: typeof ATLAS_PATTERN_STORE
  lineSet: string[]
  matrixPreview: InstitutionMatrixRow
  unresolvedEscalation: EscalationIssue[]
  nextFieldStep: string
  holdUntil: string[]
}

export function getAnzPilotSnapshot(): AnzPilotSnapshot {
  return {
    canonicalRef: FIELD_ANZ_LINE_REF,
    institution: 'ANZ',
    status: 'mapped_ready_for_dojo_draft',
    patternStore: ATLAS_PATTERN_STORE,
    lineSet: [
      'Confirm Susan Rich account/card/access surfaces.',
      'Trace the $1,100 pension-related payment(s): source, remitter, references, frequency, and missing continuation.',
      'Confirm whether any recent card/account/identity-verification activity occurred after 1 June 2026.',
      "Confirm what protective flags can be placed on Susan's profile under POA/vulnerable-customer handling.",
    ],
    matrixPreview: {
      bank: 'ANZ',
      asked: 4,
      answered: 0,
      ignored: 0,
      wrongSurface: 0,
      redirected: 0,
      contradicted: 0,
      noResponse: 0,
    },
    unresolvedEscalation: [
      {
        issueId: 'ANZ-U-001',
        institution: 'ANZ',
        text: '$1,100 pension receipt — source, remitter, frequency, continuation',
        category: 'pension_payment_routing',
        score: 0,
      },
      {
        issueId: 'ANZ-U-002',
        institution: 'ANZ',
        text: 'Card / licence / Mt Eliza instruction trail',
        category: 'card_issue_activation',
        score: 0,
      },
      {
        issueId: 'ANZ-U-005',
        institution: 'ANZ',
        text: 'POA / vulnerable-customer protective flags',
        category: 'vulnerable_customer_protection',
        score: 0,
      },
    ],
    nextFieldStep: '◼︎ DOJO — draft letter from question_map only; no narrative dump',
    holdUntil: [
      'AKRON evidence pins for statement archive / card docs (or explicit Unknown.* with human override)',
      'ANZ contact channel confirmed (not Unknown.contact)',
      'DOJO Comms render + authorize receipt',
    ],
  }
}

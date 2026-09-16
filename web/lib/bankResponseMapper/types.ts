/**
 * Bank Response Pattern Mapper — types
 *
 * Consumer of ▲ATLAS pattern store:
 *   /Users/field/▲ATLAS/▲investigation/▲bank_response_patterns/
 *
 * Invariant: drafts only after pattern map; no isolated bank letters.
 */

export type Institution =
  | 'ANZ'
  | 'NAB'
  | 'BEKB'
  | 'Rothschild'
  | 'Bank_Austria'
  | 'CBA'
  | 'Bendigo'
  | 'Westpac'
  | 'Citibank_NY'
  | 'Unknown'

export type ResponseClassification =
  | 'FIXED'
  | 'CONFIRMED'
  | 'CLARIFIED'
  | 'ASKED_FOR_MORE'
  | 'ANSWERED_WRONG_SURFACE'
  | 'PARTIAL_RESPONSE'
  | 'IGNORED_CORE_QUESTION'
  | 'EVADED'
  | 'DENIED_WITH_REASON'
  | 'DENIED_WITHOUT_REASON'
  | 'REDIRECTED'
  | 'CIRCULAR_LOOP'
  | 'CONTRADICTED_PRIOR_RECORD'
  | 'NO_RESPONSE'
  | 'REVEALS_NEW_PROCESS'

export type QuestionCategory =
  | 'poa_recognition'
  | 'account_discovery'
  | 'transaction_trace'
  | 'international_payment_source'
  | 'card_issue_activation'
  | 'online_access_logs'
  | 'third_party_authority'
  | 'deceased_estate_authority'
  | 'complaint_reference_handling'
  | 'vulnerable_customer_protection'
  | 'pension_payment_routing'
  | 'internal_notes_call_records'
  | 'account_closure_transfer_history'

export type PulseStatus =
  | 'intake'
  | 'witnessed'
  | 'chronologized'
  | 'questions_extracted'
  | 'awaiting_response'
  | 'response_classified'
  | 'patterned'
  | 'next_move_drafted'
  | 'sealed'
  | 'hold'

export type SourceMailbox =
  | 'jeremy_rich'
  | 'susan_janet_rich'
  | 'jacques_rich'
  | 'berjak_business'
  | 'ansevata_business'
  | 'trust_company'
  | 'bank_generated'

export type Channel =
  | 'email'
  | 'bank_letter'
  | 'pdf'
  | 'statement'
  | 'portal_message'
  | 'complaint_reply'
  | 'branch_note'
  | 'call_record'

/** Escalation readiness 0–5 */
export type EscalationScore = 0 | 1 | 2 | 3 | 4 | 5

export interface EvidencePin {
  name: string
  akronRef: string
  sha256?: string
}

export interface QuestionAsked {
  questionId: string
  pulseRef: string
  questionText: string
  category: QuestionCategory
  targetSurface: string
  answered: boolean
  answerExcerpt: string
  responseClassification: ResponseClassification | ''
  unresolved: boolean
}

export interface CommunicationPulse {
  pulseId: string
  institution: Institution
  bankSurface: string
  sender: string
  recipient: string
  sourceEmailAccount: SourceMailbox
  dateSent?: string
  dateReceived?: string
  subject: string
  threadId: string
  channel: Channel
  accountOrProduct: string
  personOrEntity: string
  authorityBasis: string
  evidenceAttached: EvidencePin[]
  questionsAsked: QuestionAsked[]
  responseReceived: boolean
  responseDate?: string
  responseClassification?: ResponseClassification
  ignoredQuestions: string[]
  answeredQuestions: string[]
  wrongSurfaceAnswered: boolean
  contradictionsCreated: string[]
  nextMove: string
  status: PulseStatus
  sensitivity: 'open' | 'internal' | 'confidential'
  akronBodyRef?: string
}

export interface InstitutionMatrixRow {
  bank: Institution
  asked: number
  answered: number
  ignored: number
  wrongSurface: number
  redirected: number
  contradicted: number
  noResponse: number
}

export interface CircularityLoop {
  patternId: string
  institution: Institution
  path: string[]
  escalationValue: EscalationScore
}

export interface EscalationIssue {
  issueId: string
  institution: Institution
  text: string
  category: QuestionCategory | string
  score: EscalationScore
}

export const ATLAS_PATTERN_STORE =
  '/Users/field/▲ATLAS/▲investigation/▲bank_response_patterns'

export const CLASSIFICATION_MEANINGS: Record<ResponseClassification, string> = {
  FIXED: 'They actually resolved the issue',
  CONFIRMED: 'They confirmed a fact, account state, authority, transaction, or timeline',
  CLARIFIED: 'They gave useful but incomplete information',
  ASKED_FOR_MORE: 'They requested ID, POA, forms, or extra documents',
  ANSWERED_WRONG_SURFACE: 'They responded about the wrong account, person, entity, or issue',
  PARTIAL_RESPONSE: 'They answered one question and ignored others',
  IGNORED_CORE_QUESTION: 'They replied but avoided the main issue',
  EVADED: 'They appeared responsive but did not answer substance',
  DENIED_WITH_REASON: 'They denied and gave a reason',
  DENIED_WITHOUT_REASON: 'They denied without proper basis',
  REDIRECTED: 'They sent you to another department, branch, institution, or regulator',
  CIRCULAR_LOOP: 'They repeated a prior step already completed',
  CONTRADICTED_PRIOR_RECORD: 'Their answer conflicts with another document',
  NO_RESPONSE: 'No response within the response window',
  REVEALS_NEW_PROCESS: 'Their reply opens a new issue or hidden process',
}

export const ESCALATION_MEANINGS: Record<EscalationScore, string> = {
  0: 'Intake only',
  1: 'One anchored request sent',
  2: 'Bank response received',
  3: 'Core question ignored or contradicted',
  4: 'Follow-up sent with contradiction map',
  5: 'Ready for formal complaint / AFCA / regulator / solicitor',
}

/** Phase 1 ANZ line set — canonical ref */
export const FIELD_ANZ_LINE_REF = 'FIELD-ANZ-20260714-001'

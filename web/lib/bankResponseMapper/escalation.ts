/**
 * Escalation readiness scoring (0–5) + circularity helpers.
 */

import type {
  CommunicationPulse,
  EscalationIssue,
  EscalationScore,
  CircularityLoop,
  ResponseClassification,
} from './types'
import { isSignatureAvoidance } from './matrix'

const CORE_IGNORE: ResponseClassification[] = [
  'IGNORED_CORE_QUESTION',
  'EVADED',
  'CONTRADICTED_PRIOR_RECORD',
  'ANSWERED_WRONG_SURFACE',
  'CIRCULAR_LOOP',
]

/**
 * Score one issue from pulse history for that issue's questions.
 * Rules follow module §7.D.
 */
export function scoreEscalation(input: {
  requestSent: boolean
  responseReceived: boolean
  coreIgnoredOrContradicted: boolean
  followUpWithContradictionMapSent: boolean
  readyForFormalComplaint: boolean
}): EscalationScore {
  if (input.readyForFormalComplaint) return 5
  if (input.followUpWithContradictionMapSent) return 4
  if (input.coreIgnoredOrContradicted) return 3
  if (input.responseReceived) return 2
  if (input.requestSent) return 1
  return 0
}

/** Derive escalation inputs from pulses sharing an issue/line ref in subject or nextMove. */
export function deriveEscalationFromPulses(
  issueId: string,
  text: string,
  category: string,
  pulses: CommunicationPulse[],
): EscalationIssue {
  const related = pulses.filter(
    p =>
      p.pulseId.includes(issueId) ||
      p.nextMove.includes(issueId) ||
      p.subject.includes(issueId) ||
      p.questionsAsked.some(q => q.questionId === issueId || q.questionText.includes(text.slice(0, 40))),
  )

  const requestSent = related.some(
    p =>
      p.status === 'awaiting_response' ||
      p.status === 'response_classified' ||
      p.status === 'patterned' ||
      p.status === 'next_move_drafted' ||
      p.status === 'sealed' ||
      (p.sourceEmailAccount !== 'bank_generated' && Boolean(p.dateSent)),
  )

  const responseReceived = related.some(p => p.responseReceived)

  const coreIgnoredOrContradicted = related.some(p => {
    const c = p.responseClassification
    if (c && CORE_IGNORE.includes(c)) return true
    return p.questionsAsked.some(
      q => q.responseClassification && CORE_IGNORE.includes(q.responseClassification),
    )
  })

  const followUpWithContradictionMapSent = related.some(
    p =>
      p.contradictionsCreated.length > 0 &&
      (p.status === 'next_move_drafted' || p.status === 'sealed' || Boolean(p.dateSent)),
  )

  // Score 5 is human/solicitor gate — never auto-promote
  const score = scoreEscalation({
    requestSent,
    responseReceived,
    coreIgnoredOrContradicted,
    followUpWithContradictionMapSent,
    readyForFormalComplaint: false,
  })

  const institution = related[0]?.institution ?? 'Unknown'

  return {
    issueId,
    institution,
    text,
    category,
    score,
  }
}

export function buildCircularityLoops(
  labeled: Array<{
    patternId: string
    institution: CommunicationPulse['institution']
    path: string[]
    escalationValue: EscalationScore
  }>,
): CircularityLoop[] {
  return labeled.map(l => ({
    patternId: l.patternId,
    institution: l.institution,
    path: l.path,
    escalationValue: l.escalationValue,
  }))
}

/** Gate: DOJO may draft only when pattern status allows */
export function mayDraftLetter(args: {
  questionsExtracted: boolean
  contactChannelKnown: boolean
  akronPinsOrExplicitUnknown: boolean
}): { go: boolean; holdReasons: string[] } {
  const holdReasons: string[] = []
  if (!args.questionsExtracted) holdReasons.push('questions_not_extracted')
  if (!args.contactChannelKnown) holdReasons.push('contact_channel_Unknown')
  if (!args.akronPinsOrExplicitUnknown) holdReasons.push('akron_evidence_unpinned')
  return { go: holdReasons.length === 0, holdReasons }
}

export { isSignatureAvoidance }

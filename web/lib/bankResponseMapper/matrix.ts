/**
 * Institution Response Matrix + Question Heat Map builders.
 */

import type {
  CommunicationPulse,
  Institution,
  InstitutionMatrixRow,
  QuestionCategory,
  QuestionAsked,
  ResponseClassification,
} from './types'

const INSTITUTION_ORDER: Institution[] = [
  'ANZ',
  'NAB',
  'BEKB',
  'Rothschild',
  'Bank_Austria',
  'CBA',
  'Bendigo',
  'Westpac',
  'Citibank_NY',
]

function emptyRow(bank: Institution): InstitutionMatrixRow {
  return {
    bank,
    asked: 0,
    answered: 0,
    ignored: 0,
    wrongSurface: 0,
    redirected: 0,
    contradicted: 0,
    noResponse: 0,
  }
}

function isIgnored(c: ResponseClassification | '' | undefined): boolean {
  return (
    c === 'IGNORED_CORE_QUESTION' ||
    c === 'EVADED' ||
    c === 'PARTIAL_RESPONSE'
  )
}

/** Build Institution Response Matrix from pulses (question-level). */
export function buildInstitutionMatrix(
  pulses: CommunicationPulse[],
): InstitutionMatrixRow[] {
  const map = new Map<Institution, InstitutionMatrixRow>()
  for (const bank of INSTITUTION_ORDER) map.set(bank, emptyRow(bank))

  for (const pulse of pulses) {
    const row = map.get(pulse.institution) ?? emptyRow(pulse.institution)
    const questions =
      pulse.questionsAsked.length > 0
        ? pulse.questionsAsked
        : ([{ answered: false, responseClassification: pulse.responseClassification ?? '' }] as Pick<
            QuestionAsked,
            'answered' | 'responseClassification'
          >[])

    for (const q of questions) {
      row.asked += 1
      if (q.answered) row.answered += 1
      const c = q.responseClassification || pulse.responseClassification
      if (isIgnored(c)) row.ignored += 1
      if (c === 'ANSWERED_WRONG_SURFACE' || pulse.wrongSurfaceAnswered) row.wrongSurface += 1
      if (c === 'REDIRECTED') row.redirected += 1
      if (c === 'CONTRADICTED_PRIOR_RECORD') row.contradicted += 1
      if (c === 'NO_RESPONSE') row.noResponse += 1
    }
    map.set(pulse.institution, row)
  }

  return INSTITUTION_ORDER.map(b => map.get(b)!).filter(
    r => r.asked > 0 || r.bank === 'ANZ' || r.bank === 'NAB',
  )
}

/** Category → ignore/evade/wrong-surface counts */
export function buildQuestionHeatMap(
  pulses: CommunicationPulse[],
): Record<QuestionCategory | string, { asked: number; avoided: number }> {
  const heat: Record<string, { asked: number; avoided: number }> = {}

  for (const pulse of pulses) {
    for (const q of pulse.questionsAsked) {
      const bucket = heat[q.category] ?? { asked: 0, avoided: 0 }
      bucket.asked += 1
      const c = q.responseClassification || pulse.responseClassification
      if (
        !q.answered ||
        isIgnored(c) ||
        c === 'ANSWERED_WRONG_SURFACE' ||
        c === 'NO_RESPONSE' ||
        c === 'REDIRECTED'
      ) {
        bucket.avoided += 1
      }
      heat[q.category] = bucket
    }
  }
  return heat
}

/** Classify whether a pulse reply is "responsive but empty" */
export function isSignatureAvoidance(c: ResponseClassification | undefined): boolean {
  if (!c) return false
  return (
    c === 'PARTIAL_RESPONSE' ||
    c === 'ANSWERED_WRONG_SURFACE' ||
    c === 'IGNORED_CORE_QUESTION' ||
    c === 'EVADED' ||
    c === 'REDIRECTED' ||
    c === 'CIRCULAR_LOOP' ||
    c === 'NO_RESPONSE'
  )
}

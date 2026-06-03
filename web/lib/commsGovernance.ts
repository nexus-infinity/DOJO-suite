/**
 * Comms Autopilot — Governance Layer
 *
 * Invariant: "Rendered content is not an action until it has an authorization receipt,
 * and the transport layer may only replay that receipt."
 *
 * Pipeline: Render → Authorize → Execute
 * HOLD is fail-closed. Unknown pins block execution.
 */

import { createHash } from 'crypto'

// ── Schema ─────────────────────────────────────────────────────────────────

export type TemplateCapabilityClass = 'LOW' | 'MEDIUM' | 'HIGH' | 'RESTRICTED'
export type AllowedAutonomyLevel    = 'draft_only' | 'manual_send' | 'auto_send'
export type AssertionScope =
  | 'informational'
  | 'procedural'
  | 'financial'
  | 'legal-risk'
  | 'timeline-dependent'
  | 'evidence-incomplete'
  | 'Unknown'

export type OriginType      = 'HUMAN' | 'IMPORTED' | 'AUTO_GENERATED'
export type AuthScope       = 'draft_only' | 'send_low' | 'send_med' | 'send_high' | 'restricted'
export type PolicyDecision  = 'GO' | 'HOLD'

// What the caller provides
export interface OutboundAttempt {
  // Identity
  messageId:         string
  canonicalRef:      string               // case/thread ref or 'Unknown'
  processingId:      string               // queue row id or 'Unknown'
  templateId:        string               // template name/id
  templateVersionHash: string             // sha256 of template content at render time

  // Content (normalized — strip leading/trailing whitespace, collapse internal ws)
  subjectNormalized: string
  bodyNormalized:    string
  attachmentManifest: AttachmentPin[]     // empty array if none

  // Classification
  assertionScope:    AssertionScope
  capabilityClass:   TemplateCapabilityClass
  autonomyLevel:     AllowedAutonomyLevel

  // Anti-recursion
  originType:        OriginType
  originAnchor:      string               // gmail msg id / notion page / webhook id
  automationDepth:   number               // 0 = human-initiated

  // Human confirmation (required for HIGH/RESTRICTED)
  humanToken?:       string
}

export interface AttachmentPin {
  name:      string
  mime:      string
  byteLength: number
  sha256:    string
}

export interface AuthReceipt {
  valid:         boolean
  decision:      PolicyDecision
  fingerprint:   string
  authScope:     AuthScope
  authActor:     'human' | 'system'
  gatesPassed:   string[]
  holdReasons:   string[]
  timestamp:     string
}

export interface RenderOutput {
  subject:       string
  body:          string
  renderHash:    string   // sha256 of subject+body at render time
  renderedAt:    string
}

// ── Fingerprint ─────────────────────────────────────────────────────────────

/** 5-minute timestamp bucket — prevents duplicate detection from clock skew */
function timestampBucket(now = new Date()): string {
  const ms = Math.floor(now.getTime() / (5 * 60 * 1000)) * (5 * 60 * 1000)
  return new Date(ms).toISOString()
}

function attachmentManifestHash(pins: AttachmentPin[]): string {
  if (pins.length === 0) return 'none'
  const manifest = pins
    .map(p => `${p.name}|${p.mime}|${p.byteLength}|${p.sha256}`)
    .sort()
    .join('::')
  return createHash('sha256').update(manifest).digest('hex')
}

export function generateMessageFingerprint(attempt: OutboundAttempt, now = new Date()): string {
  const components = [
    attempt.canonicalRef,
    attempt.processingId,
    attempt.templateId,
    attempt.templateVersionHash,
    attempt.subjectNormalized,
    attempt.bodyNormalized,
    attachmentManifestHash(attempt.attachmentManifest),
    timestampBucket(now),
  ].join('|')
  return createHash('sha256').update(components).digest('hex')
}

// ── Render ───────────────────────────────────────────────────────────────────

/** Normalize text: trim + collapse internal whitespace */
export function normalizeText(s: string): string {
  return s.trim().replace(/\s+/g, ' ')
}

export function buildRenderOutput(subject: string, body: string): RenderOutput {
  const hash = createHash('sha256').update(`${subject}|||${body}`).digest('hex')
  return {
    subject,
    body,
    renderHash: hash,
    renderedAt: new Date().toISOString(),
  }
}

// ── Authorize ─────────────────────────────────────────────────────────────────

const REQUIRES_HUMAN_TOKEN: TemplateCapabilityClass[] = ['HIGH', 'RESTRICTED']

export function authorizeSend(attempt: OutboundAttempt, render: RenderOutput): AuthReceipt {
  const now      = new Date().toISOString()
  const holdReasons: string[] = []
  const gatesPassed: string[] = []

  // Gate 1: Unknown assertion_scope → draft_only
  if (attempt.assertionScope === 'Unknown') {
    holdReasons.push('assertion_scope is Unknown — defaulting to HOLD')
  } else {
    gatesPassed.push('assertion_scope_known')
  }

  // Gate 2: Unknown canonical pins
  if (attempt.canonicalRef === 'Unknown' || attempt.processingId === 'Unknown') {
    holdReasons.push('canonical_ref or processing_id is Unknown')
  } else {
    gatesPassed.push('canonical_pins_present')
  }

  // Gate 3: legal-risk scope enforces HIGH/RESTRICTED
  if (
    attempt.assertionScope === 'legal-risk' &&
    !['HIGH', 'RESTRICTED'].includes(attempt.capabilityClass)
  ) {
    holdReasons.push('legal-risk assertion_scope requires HIGH or RESTRICTED capability class')
  } else if (attempt.assertionScope !== 'Unknown') {
    gatesPassed.push('scope_capability_alignment')
  }

  // Gate 4: anti-recursion
  if (attempt.originType === 'AUTO_GENERATED' && attempt.automationDepth >= 1) {
    if (['HIGH', 'RESTRICTED'].includes(attempt.capabilityClass)) {
      holdReasons.push('AUTO_GENERATED with depth >= 1 cannot execute HIGH/RESTRICTED')
    }
    if (attempt.autonomyLevel !== 'draft_only') {
      holdReasons.push('AUTO_GENERATED with depth >= 1 requires draft_only autonomy')
    }
  } else {
    gatesPassed.push('anti_recursion')
  }

  // Gate 5: human token for HIGH/RESTRICTED
  if (REQUIRES_HUMAN_TOKEN.includes(attempt.capabilityClass)) {
    if (!attempt.humanToken?.trim()) {
      holdReasons.push(`${attempt.capabilityClass} capability requires human confirmation token`)
    } else {
      gatesPassed.push('human_token_present')
    }
  } else {
    gatesPassed.push('capability_class_gate')
  }

  // Gate 6: render hash integrity (detect mutation between render and authorize)
  const expectedRenderHash = createHash('sha256')
    .update(`${render.subject}|||${render.body}`)
    .digest('hex')
  if (expectedRenderHash !== render.renderHash) {
    holdReasons.push('render_hash mismatch — content mutated between render and authorize')
  } else {
    gatesPassed.push('render_integrity')
  }

  const valid    = holdReasons.length === 0
  const decision: PolicyDecision = valid ? 'GO' : 'HOLD'

  // Derive auth scope from capability class (draft_only overrides autonomy)
  let authScope: AuthScope = 'draft_only'
  if (valid && attempt.autonomyLevel !== 'draft_only') {
    const scopeMap: Record<TemplateCapabilityClass, AuthScope> = {
      LOW:        'send_low',
      MEDIUM:     'send_med',
      HIGH:       'send_high',
      RESTRICTED: 'restricted',
    }
    authScope = scopeMap[attempt.capabilityClass]
  }

  return {
    valid,
    decision,
    fingerprint: generateMessageFingerprint(attempt),
    authScope,
    authActor:   attempt.humanToken ? 'human' : 'system',
    gatesPassed,
    holdReasons,
    timestamp:   now,
  }
}

// ── Audit log entry ──────────────────────────────────────────────────────────

export interface CommsSendAttemptLog {
  fingerprint:    string
  messageId:      string
  canonicalRef:   string
  templateId:     string
  assertionScope: AssertionScope
  capabilityClass: TemplateCapabilityClass
  autonomyLevel:  AllowedAutonomyLevel
  originType:     OriginType
  automationDepth: number
  decision:       PolicyDecision
  authScope:      AuthScope
  holdReasons:    string[]
  gatesPassed:    string[]
  timestamp:      string
}

export function buildAuditEntry(
  attempt: OutboundAttempt,
  receipt: AuthReceipt
): CommsSendAttemptLog {
  return {
    fingerprint:     receipt.fingerprint,
    messageId:       attempt.messageId,
    canonicalRef:    attempt.canonicalRef,
    templateId:      attempt.templateId,
    assertionScope:  attempt.assertionScope,
    capabilityClass: attempt.capabilityClass,
    autonomyLevel:   attempt.autonomyLevel,
    originType:      attempt.originType,
    automationDepth: attempt.automationDepth,
    decision:        receipt.decision,
    authScope:       receipt.authScope,
    holdReasons:     receipt.holdReasons,
    gatesPassed:     receipt.gatesPassed,
    timestamp:       receipt.timestamp,
  }
}

/**
 * POST /api/comms/send
 *
 * 3-step governance pipeline: Render → Authorize → Execute
 * Transport is draft_only until bridges are wired; governance gates are live now.
 *
 * Body: SendRequest
 * Returns: SendResponse (always includes auth receipt + audit fingerprint)
 */

import { type NextRequest, NextResponse } from 'next/server'
import {
  buildRenderOutput,
  normalizeText,
  authorizeSend,
  buildAuditEntry,
  type OutboundAttempt,
  type TemplateCapabilityClass,
  type AssertionScope,
  type OriginType,
} from '@/lib/commsGovernance'

interface SendRequest {
  // Required
  messageId:        string
  text:             string

  // Governance pins (callers must provide; Unknown triggers HOLD)
  canonicalRef?:    string
  templateId?:      string
  assertionScope?:  AssertionScope
  capabilityClass?: TemplateCapabilityClass
  originType?:      OriginType
  automationDepth?: number
  humanToken?:      string

  // Optional context
  subject?:         string
  processingId?:    string
}

export async function POST(req: NextRequest) {
  let body: SendRequest
  try {
    body = await req.json()
  } catch {
    return NextResponse.json({ error: 'Invalid JSON' }, { status: 400 })
  }

  const { messageId, text } = body
  if (!messageId || !text?.trim()) {
    return NextResponse.json({ error: 'messageId and text are required' }, { status: 400 })
  }

  // ── Step 1: Render ──────────────────────────────────────────────────────
  const subject  = normalizeText(body.subject ?? `Re: ${messageId}`)
  const bodyNorm = normalizeText(text)
  const render   = buildRenderOutput(subject, bodyNorm)

  // ── Step 2: Authorize ────────────────────────────────────────────────────
  const attempt: OutboundAttempt = {
    messageId,
    canonicalRef:        body.canonicalRef        ?? 'Unknown',
    processingId:        body.processingId        ?? 'Unknown',
    templateId:          body.templateId          ?? 'freeform',
    templateVersionHash: render.renderHash,         // freeform: hash of content itself
    subjectNormalized:   subject,
    bodyNormalized:      bodyNorm,
    attachmentManifest:  [],
    assertionScope:      body.assertionScope      ?? 'Unknown',
    capabilityClass:     body.capabilityClass     ?? 'LOW',
    autonomyLevel:       'draft_only',              // locked until transport bridges live
    originType:          body.originType          ?? 'HUMAN',
    originAnchor:        messageId,
    automationDepth:     body.automationDepth     ?? 0,
    humanToken:          body.humanToken,
  }

  const receipt    = authorizeSend(attempt, render)
  const auditEntry = buildAuditEntry(attempt, receipt)

  // T+0: append to log immediately (even on HOLD — HOLD is not silence)
  console.log('[Foreman] send attempt:', JSON.stringify(auditEntry))

  // ── Step 3: Execute ──────────────────────────────────────────────────────
  // Transport is draft_only: gates enforced, no message sent until bridges live.
  //
  // When Matrix bridges ready, add before routing:
  //   if (receipt.valid && receipt.authScope !== 'draft_only') { ...route... }
  //
  // Bridge routing:
  //   email     → nodemailer/SMTP     (mode → signature mapping below)
  //   whatsapp  → Matrix WA bridge
  //   imessage  → Matrix iMessage bridge
  //   signal    → Matrix Signal bridge
  //
  // Email mode → signature:
  //   personal   → jeremy.rich@berjak.com.au  (● #5b8db8)
  //   business   → info@berjak.com.au          (▲ #5a7a5a)
  //   legal      → accounts@berjak.com.au      (▼ #8b4a4a)
  //   regulatory → operations@berjak.com.au    (◼ #6b5b7b)

  if (!receipt.valid) {
    return NextResponse.json(
      {
        ok:          false,
        decision:    'HOLD',
        fingerprint: receipt.fingerprint,
        holdReasons: receipt.holdReasons,
        gatesPassed: receipt.gatesPassed,
        authScope:   receipt.authScope,
        messageId,
      },
      { status: 422 }
    )
  }

  return NextResponse.json({
    ok:          true,
    decision:    'GO',
    fingerprint: receipt.fingerprint,
    authScope:   receipt.authScope,      // 'draft_only' until bridges live
    gatesPassed: receipt.gatesPassed,
    messageId,
    note:        'Draft authorized. Transport not yet wired — message not sent.',
  })
}

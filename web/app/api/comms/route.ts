// GET /api/comms — returns messages from all bridges
// Stub now; Matrix bridge adapter wires in when Gemini's synopsis is ready
// Messages are returned unscored — TG computed client-side in ForemanPanel

import { type NextRequest, NextResponse } from 'next/server'
import type { CommMessage } from '@/components/field/ForemanPanel'

type RawMessage = Omit<CommMessage, 'tg' | 'tgFactors'>

// ── Mock data — replace with Matrix bridge queries ────────────────────────────
const MOCK_MESSAGES: RawMessage[] = [
  {
    id: 'swiss-001',
    channel: 'email',
    mode: 'regulatory',
    from: 'BEKB — Bernische Kantonalbank',
    fromHandle: 'info@bekb.ch',
    body: 'Regarding your foreclosure notice dated 10 April 2026 — please respond within 10 business days with the required documentation.',
    receivedAt: new Date(Date.now() - 2 * 3_600_000).toISOString(),
    caseRef: 'BEKB/2026/04/JR',
    status: 'unread',
  },
  {
    id: 'ira-001',
    channel: 'whatsapp',
    mode: 'legal',
    from: 'Ira',
    body: "I still haven't received consent from your side regarding the estate distribution. We need to move forward.",
    receivedAt: new Date(Date.now() - 5 * 3_600_000).toISOString(),
    threadId: 'ira-estate-thread',
    status: 'unread',
  },
  {
    id: 'david-001',
    channel: 'imessage',
    mode: 'legal',
    from: 'David Rich',
    body: "Can you call me when you have a moment. There's something we need to talk about regarding dad's estate.",
    receivedAt: new Date(Date.now() - 8 * 3_600_000).toISOString(),
    threadId: 'david-estate-thread',
    status: 'unread',
  },
  {
    id: 'berjak-001',
    channel: 'email',
    mode: 'business',
    from: 'Berjak Client — Meridian Structures',
    fromHandle: 'j.white@meridian.com.au',
    body: 'Following up on the invoice from March. When can we expect the updated quote for Phase 2?',
    receivedAt: new Date(Date.now() - 18 * 3_600_000).toISOString(),
    status: 'unread',
  },
  {
    id: 'mum-001',
    channel: 'imessage',
    mode: 'personal',
    from: 'Mum (Susan)',
    body: "Darling are you coming over for dinner Sunday? I'm making the lamb.",
    receivedAt: new Date(Date.now() - 24 * 3_600_000).toISOString(),
    status: 'unread',
  },
  {
    id: 'noise-001',
    channel: 'email',
    mode: 'personal',
    from: 'noreply@newsletter.com',
    body: 'Special offer — unsubscribe at any time. 50% off all products this weekend only!',
    receivedAt: new Date(Date.now() - 30 * 3_600_000).toISOString(),
    status: 'unread',
  },
]

export async function GET(_req: NextRequest) {
  // TODO: Replace MOCK_MESSAGES with real bridge queries:
  // - Matrix homeserver API (WhatsApp, Signal, Messenger, Google Chat bridges)
  // - IMAP / Gmail API for email channels (● ▲ ▼ ◼ modes)
  // - iMessage bridge when configured
  // - Akron evidence-linked threads (high TG by definition)

  return NextResponse.json(MOCK_MESSAGES)
}

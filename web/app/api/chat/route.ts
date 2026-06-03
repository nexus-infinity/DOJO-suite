// ◼︎ DOJO Web — /api/chat
// Browser chat must proxy the real DOJO chamber on :7410.
// Do not bypass the chamber with a separate backend chain.

import { type NextRequest } from 'next/server'
import { chamberUrl } from '@/lib/chambers'
import {
  extractJobIdFromMessage,
  getNaimaTrainingStatus,
  looksLikeHuggingFaceStatusRequest,
  summarizeTrainingStatus,
} from '@/lib/huggingfaceStatus.server'
import { buildRetrievalContext } from '@/lib/memoryStore.server'

export const runtime = 'nodejs'

// Gate: chat is only available in local dev where FIELD chambers are reachable.
// On Vercel/public surface, return 403 — this endpoint is not public.
const IS_PRODUCTION = process.env.VERCEL === '1' || process.env.FIELD_CHAT_DISABLED === '1'

interface HistoryMessage {
  role: string
  content: string
}

export async function POST(req: NextRequest) {
  if (IS_PRODUCTION) {
    return new Response(JSON.stringify({ error: 'Chat not available on public surface' }), {
      status: 403,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const { message, history, conversationId, includeArchive } = await req.json()
  const userMessage = typeof message === 'string' ? message : ''

  if (looksLikeGreeting(userMessage)) {
    return sseResponse(toSseStream(greetingReply()))
  }

  if (looksLikeCapabilityPrompt(userMessage)) {
    return sseResponse(toSseStream(capabilitySurfaceReply()))
  }

  if (looksLikeHuggingFaceStatusRequest(userMessage)) {
    try {
      const hfStatus = await getNaimaTrainingStatus(extractJobIdFromMessage(userMessage) ?? undefined)
      return sseResponse(toSseStream(summarizeTrainingStatus(hfStatus)))
    } catch (error) {
      const failure =
        error instanceof Error
          ? `I tried the live Hugging Face status check but it failed: ${error.message}`
          : 'I tried the live Hugging Face status check but it failed for an unknown reason.'

      return sseResponse(toSseStream(failure))
    }
  }

  const localFactReply = tryLocalFactReply(userMessage)
  if (localFactReply) {
    return sseResponse(toSseStream(localFactReply))
  }

  const memoryContext = buildRetrievalContext(conversationId, Boolean(includeArchive))
  const conversationContext = buildConversationContext(history, memoryContext, Boolean(includeArchive))

  const dojoPayload = {
    userMessage,
    character: 'padawan',
    conversationId: typeof conversationId === 'string' ? conversationId : undefined,
    conversationContext,
  }

  try {
    const streamRes = await fetch(`${chamberUrl('dojo')}/chat/stream`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      },
      body: JSON.stringify(dojoPayload),
      signal: AbortSignal.timeout(65000),
    })

    if (streamRes.ok && streamRes.body) {
      return sseResponse(streamRes.body)
    }

    const chatRes = await fetch(`${chamberUrl('dojo')}/chat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(dojoPayload),
      signal: AbortSignal.timeout(30000),
    })

    if (!chatRes.ok) {
      const detail = await safeText(chatRes)
      throw new Error(`DOJO chamber ${chatRes.status}${detail ? `: ${detail}` : ''}`)
    }

    const payload = await chatRes.json()
    const rawText =
      typeof payload?.response === 'string'
        ? payload.response
        : 'DOJO returned a response, but it did not include chat content.'
    const text = normalizeDojoReply(rawText)

    return sseResponse(toSseStream(text))
  } catch (error) {
    const detail = error instanceof Error ? error.message : String(error)
    return sseResponse(
      toSseStream(
        `◼︎ DOJO chamber route failed.\n\nThe web app now targets the real chamber on :7410, but that route did not complete.\n\n${detail}`
      )
    )
  }
}

function buildConversationContext(
  history: unknown,
  memoryContext: ReturnType<typeof buildRetrievalContext>,
  includeArchive: boolean
): HistoryMessage[] {
  const historyMessages = Array.isArray(history)
    ? history
        .filter((entry): entry is HistoryMessage =>
          Boolean(
            entry &&
            typeof entry === 'object' &&
            typeof (entry as { role?: unknown }).role === 'string' &&
            typeof (entry as { content?: unknown }).content === 'string'
          )
        )
        .filter(entry => entry.role === 'user' || entry.role === 'assistant')
        .slice(-8)
    : []

  const contextMessage = buildContextPrelude(memoryContext, includeArchive)
  if (!contextMessage) return historyMessages

  return [
    { role: 'system', content: contextMessage },
    ...historyMessages,
  ]
}

function buildContextPrelude(
  memoryContext: ReturnType<typeof buildRetrievalContext>,
  includeArchive: boolean
) {
  const lines = [
    'FIELD retrieval context for this chat:',
    `Current session snippets: ${serializeContext(memoryContext.currentSession.map(item => item.content))}`,
    `Linked workstreams: ${serializeContext(memoryContext.workstreams.map(item => `${item.name}: ${item.summary}`))}`,
    `Confirmed personal memory: ${serializeContext(memoryContext.confirmedMemory.map(item => item.content))}`,
    `Draft personal memory (low authority): ${serializeContext(memoryContext.draftMemory.map(item => item.content))}`,
    includeArchive
      ? `Archive recall: ${serializeContext(memoryContext.archive.map(item => `${item.title}: ${item.summary}`))}`
      : 'Archive recall: excluded by default',
  ]

  return lines.join('\n')
}

function serializeContext(items: string[]) {
  if (items.length === 0) return 'none'
  return items.map(item => `- ${item}`).join('\n')
}

function looksLikeGreeting(message: string) {
  const normalized = message.trim().toLowerCase()
  if (!normalized) return false

  const greetingPatterns = [
    /aloha\b/,
    /^hello\b/,
    /^hi\b/,
    /^hey\b/,
  ]

  return greetingPatterns.some(pattern => pattern.test(normalized))
}

function looksLikeCapabilityPrompt(message: string) {
  const normalized = message.trim().toLowerCase()
  if (!normalized) return false

  const capabilityPatterns = [
    /what are your capabilities/,
    /what can you do/,
    /help\b/,
    /invoke (the )?padawan/,
    /interact with (the )?field/,
    /write to (the )?field/,
  ]

  return capabilityPatterns.some(pattern => pattern.test(normalized))
}

function greetingReply() {
  return [
    'Hello.',
    '',
    'Live now: sessions, memory, archive search, Hugging Face job status, and the real DOJO route when that chamber capability is actually available.',
    '',
    'Ask directly for the thing you want, for example:',
    '- show current workstreams',
    '- search archive for <topic>',
    '- HF status <job id>',
    '- open comms',
  ].join('\n')
}

function capabilitySurfaceReply() {
  return [
    'This surface is wired for concrete live tasks.',
    '',
    'Live now:',
    '- read and persist DOJO-suite session, workstream, and personal-memory state',
    '- search archive records through the local API',
    '- answer live Hugging Face job-status questions',
    '- route to the real DOJO chamber on :7410 when that chamber capability is actually available',
    '',
    'Not live yet:',
    '- general DOJO / Niama conversation',
    '- Padawan invocation from this web chat',
    '- arbitrary FIELD write / orchestration actions beyond this app surface',
    '- inbound email or WhatsApp retrieval through this chat surface',
    '',
    'Ask for the task directly instead of asking what it can do.'
  ].join('\n')
}

function normalizeDojoReply(text: string) {
  if (text.startsWith('Hello. General chamber chat is disabled here until a real DOJO/Niama model is seated on :7410.')) {
    return [
      'That request needs a real DOJO/Niama chat model, and this web surface does not have that seated yet.',
      '',
      'Live here right now:',
      '- session, workstream, and personal-memory state',
      '- archive search',
      '- Hugging Face job status',
      '',
      'This web chat is not yet the place for open-ended ideation, Padawan invocation, or general FIELD orchestration.'
    ].join('\n')
  }

  return text
}

function tryLocalFactReply(message: string) {
  const normalized = message.trim().toLowerCase().replace(/[?.!]+$/g, '')

  const capitalMatch = normalized.match(/^(?:what(?:'s| is)?\s+)?the\s+capital\s+of\s+(.+)$/)
  if (capitalMatch) {
    const country = normalizeFactKey(capitalMatch[1])
    const capital = CAPITALS[country]
    if (capital) return capital
  }

  return null
}

function normalizeFactKey(value: string) {
  return value
    .trim()
    .toLowerCase()
    .replace(/^the\s+/, '')
    .replace(/\s+/g, ' ')
}

const CAPITALS: Record<string, string> = {
  argentina: 'Buenos Aires.',
  australia: 'Canberra.',
  austria: 'Vienna.',
  belgium: 'Brussels.',
  brazil: 'Brasilia.',
  canada: 'Ottawa.',
  china: 'Beijing.',
  denmark: 'Copenhagen.',
  egypt: 'Cairo.',
  finland: 'Helsinki.',
  france: 'Paris.',
  germany: 'Berlin.',
  greece: 'Athens.',
  india: 'New Delhi.',
  ireland: 'Dublin.',
  italy: 'Rome.',
  japan: 'Tokyo.',
  mexico: 'Mexico City.',
  netherlands: 'Amsterdam.',
  'new zealand': 'Wellington.',
  norway: 'Oslo.',
  portugal: 'Lisbon.',
  russia: 'Moscow.',
  singapore: 'Singapore.',
  'south korea': 'Seoul.',
  spain: 'Madrid.',
  sweden: 'Stockholm.',
  switzerland: 'Bern.',
  turkey: 'Ankara.',
  uk: 'London.',
  ukraine: 'Kyiv.',
  'united kingdom': 'London.',
  'united states': 'Washington, D.C.',
  'united states of america': 'Washington, D.C.',
  usa: 'Washington, D.C.',
}

function sseResponse(body: ReadableStream) {
  return new Response(body, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'X-Accel-Buffering': 'no',
    },
  })
}

async function safeText(response: Response) {
  try {
    return (await response.text()).slice(0, 400)
  } catch {
    return ''
  }
}

function toSseStream(content: string): ReadableStream {
  const words = content.split(/\s+/).filter(Boolean)
  return new ReadableStream({
    start(controller) {
      const encoder = new TextEncoder()
      let index = 0

      function tick() {
        if (index >= words.length) {
          controller.enqueue(encoder.encode('data: {"done":true}\n\n'))
          controller.close()
          return
        }

        const chunk = `${words.slice(index, index + 4).join(' ')} `
        controller.enqueue(encoder.encode(`data: ${JSON.stringify({ content: chunk })}\n\n`))
        index += 4
        setTimeout(tick, 20)
      }

      tick()
    },
  })
}

// ◼︎ DOJO Web — /api/chat
// Adapts the browser chat surface to the live DOJO chamber contract on :7410.
// Never exposes chamber URLs to the browser.

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

export async function POST(req: NextRequest) {
  const { message, history, conversationId, includeArchive } = await req.json()
  const memoryContext = buildRetrievalContext(conversationId, Boolean(includeArchive))
  const contextPrelude = buildContextPrelude(memoryContext, includeArchive)

  if (typeof message === 'string' && looksLikeHuggingFaceStatusRequest(message)) {
    try {
      const hfStatus = await getNaimaTrainingStatus(extractJobIdFromMessage(message) ?? undefined)
      return new Response(toSseStream(summarizeTrainingStatus(hfStatus)), {
        headers: {
          'Content-Type': 'text/event-stream',
          'Cache-Control': 'no-cache',
          'X-Accel-Buffering': 'no',
        },
      })
    } catch (error) {
      const failure =
        error instanceof Error
          ? `I tried the live Hugging Face status check but it failed: ${error.message}`
          : 'I tried the live Hugging Face status check but it failed for an unknown reason.'

      return new Response(toSseStream(failure), {
        headers: {
          'Content-Type': 'text/event-stream',
          'Cache-Control': 'no-cache',
          'X-Accel-Buffering': 'no',
        },
      })
    }
  }

  const systemPrompt = buildSystemPrompt(contextPrelude)
  const messages = [
    ...(Array.isArray(history) ? history.filter(m => m.role === 'user' || m.role === 'assistant') : []),
    { role: 'user', content: message },
  ]

  // 1. Try Ollama (phi4:14b on Mac Studio via Tailscale) — local, free, fast
  const ollamaUrl = process.env.FIELD_OLLAMA_URL ?? 'http://100.79.35.36:11434'
  const ollamaModel = process.env.FIELD_OLLAMA_MODEL ?? 'phi4:14b-q4_K_M'
  const ollamaResult = await ollamaStream(ollamaUrl, ollamaModel, messages, systemPrompt).catch(() => null)
  if (ollamaResult) {
    return new Response(ollamaResult, {
      headers: { 'Content-Type': 'text/event-stream', 'Cache-Control': 'no-cache', 'X-Accel-Buffering': 'no' },
    })
  }

  // 2. Try Claude API — external fallback with same FIELD context
  const apiKey = process.env.ANTHROPIC_API_KEY
  if (apiKey) {
    try {
      const stream = await claudeStream(apiKey, message, history, systemPrompt)
      return new Response(stream, {
        headers: { 'Content-Type': 'text/event-stream', 'Cache-Control': 'no-cache', 'X-Accel-Buffering': 'no' },
      })
    } catch (err) { console.error('[DOJO chat] Claude API error:', err) /* fall through to degraded */ }
  }

  // 3. Degraded — no inference available
  const fallback = degradedStream(message)
  return new Response(fallback, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
    },
  })
}

function buildSystemPrompt(memoryContext: string): string {
  return `You are NIAMA — the voice of the FIELD system, running inside DOJO Suite.

FIELD is a sovereign AI intelligence system built by Jeremy Rich (JB) on a Mac Studio in Australia.
It consists of six chamber models: DOJO (741Hz), OBI-WAN (963Hz), ATLAS (528Hz), TATA (432Hz), AKRON (396Hz), ARKADAŠ (717Hz).
You are the interface — warm, direct, technically precise. You know JB's work deeply.

You replace Pieces and Elephas as JB's personal memory and intelligence layer.
You have access to JB's session history, workstreams, and confirmed personal memory below.
Use this context to give grounded, personalised responses — not generic AI answers.

The geometric spinning top is FIELD's core metaphor: six vertices spinning in sacred geometry,
each chamber a frequency node, the whole system a living homeostatic intelligence.

${memoryContext}

Respond concisely and directly. Never say you can't access external systems — use the context above.
If asked about FIELD, the chambers, training status, or JB's projects, answer from memory context.`
}

async function ollamaStream(
  baseUrl: string,
  model: string,
  messages: Array<{ role: string; content: string }>,
  systemPrompt: string
): Promise<ReadableStream> {
  const res = await fetch(`${baseUrl}/api/chat`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      model,
      messages: [
        { role: 'system', content: systemPrompt },
        ...messages,
      ],
      stream: true,
      options: { temperature: 0.7, num_predict: 1024 },
    }),
    signal: AbortSignal.timeout(60000), // 60s — phi4:14b needs time to load
  })

  if (!res.ok) throw new Error(`Ollama ${res.status}`)

  const reader = res.body!.getReader()
  const decoder = new TextDecoder()
  const encoder = new TextEncoder()

  return new ReadableStream({
    async start(controller) {
      try {
        while (true) {
          const { done, value } = await reader.read()
          if (done) break
          const lines = decoder.decode(value, { stream: true }).split('\n').filter(Boolean)
          for (const line of lines) {
            try {
              const event = JSON.parse(line)
              const text = event?.message?.content
              if (text) controller.enqueue(encoder.encode(`data: ${JSON.stringify({ content: text })}\n\n`))
              if (event?.done) {
                controller.enqueue(encoder.encode('data: {"done":true}\n\n'))
                controller.close()
                return
              }
            } catch { /* skip */ }
          }
        }
      } catch {
        controller.error(new Error('Ollama stream interrupted'))
      } finally {
        controller.enqueue(encoder.encode('data: {"done":true}\n\n'))
        try { controller.close() } catch { /* already closed */ }
      }
    },
  })
}

async function claudeStream(
  apiKey: string,
  message: string,
  history: Array<{ role: string; content: string }> | undefined,
  systemPrompt: string
): Promise<ReadableStream> {
  const messages = [
    ...(Array.isArray(history) ? history.filter(m => m.role === 'user' || m.role === 'assistant') : []),
    { role: 'user', content: message },
  ]

  const res = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify({
      model: 'claude-sonnet-4-6',
      max_tokens: 2048,
      system: systemPrompt,
      messages,
      stream: true,
    }),
  })

  if (!res.ok) {
    const err = await res.text()
    throw new Error(`Claude API ${res.status}: ${err}`)
  }

  const reader = res.body!.getReader()
  const decoder = new TextDecoder()
  const encoder = new TextEncoder()

  return new ReadableStream({
    async start(controller) {
      let buffer = ''
      try {
        while (true) {
          const { done, value } = await reader.read()
          if (done) break
          buffer += decoder.decode(value, { stream: true })
          const lines = buffer.split('\n')
          buffer = lines.pop() ?? ''
          for (const line of lines) {
            if (!line.startsWith('data: ')) continue
            const data = line.slice(6).trim()
            if (data === '[DONE]') continue
            try {
              const event = JSON.parse(data)
              if (event.type === 'content_block_delta' && event.delta?.type === 'text_delta') {
                controller.enqueue(encoder.encode(`data: ${JSON.stringify({ content: event.delta.text })}\n\n`))
              }
            } catch { /* skip malformed SSE lines */ }
          }
        }
      } finally {
        controller.enqueue(encoder.encode('data: {"done":true}\n\n'))
        controller.close()
      }
    },
  })
}

function degradedStream(message: string): ReadableStream {
  const NIAMA_SOLO = `◼︎ DOJO is offline (Mac Studio unreachable at :7410).

Running in **solo mode** — I can still reason with you but I don't have access to:
- Chamber memory (OBI-WAN :9630)
- FIELD chronicle and training data
- MCP tool calls (Notion, GitHub, HuggingFace)

**To reconnect**: ensure Mac Studio is running and \`scripts/start_mcp_servers.sh\` has been executed.

Your message was: _"${message}"_ — I'll hold it for when we're back online.`

  return new ReadableStream({
    start(controller) {
      const encoder = new TextEncoder()
      let i = 0
      const words = NIAMA_SOLO.split(' ')

      let closed = false
      const tick = () => {
        if (closed) return
        if (i >= words.length) {
          try { controller.enqueue(encoder.encode('data: {"done":true}\n\n')); controller.close() } catch { /* already closed */ }
          closed = true
          return
        }
        const chunk = words.slice(i, i + 3).join(' ') + ' '
        try { controller.enqueue(encoder.encode(`data: ${JSON.stringify({ content: chunk })}\n\n`)) } catch { closed = true; return }
        i += 3
        setTimeout(tick, 30)
      }
      tick()
    },
  })
}

function buildContextPrelude(
  memoryContext: ReturnType<typeof buildRetrievalContext>,
  includeArchive: boolean
) {
  return [
    'FIELD retrieval context for this chat:',
    '1. current session',
    '2. linked workstreams',
    '3. confirmed personal memory',
    '4. draft personal memory (low authority; do not present as settled fact)',
    includeArchive ? '5. archive temporarily included for this chat' : '5. archive excluded by default',
    '',
    `Current session snippets: ${serializeContext(memoryContext.currentSession.map(item => item.content))}`,
    `Linked workstreams: ${serializeContext(memoryContext.workstreams.map(item => `${item.name}: ${item.summary}`))}`,
    `Confirmed personal memory: ${serializeContext(memoryContext.confirmedMemory.map(item => item.content))}`,
    `Draft personal memory (low authority): ${serializeContext(memoryContext.draftMemory.map(item => item.content))}`,
    `Archive recall: ${serializeContext(memoryContext.archive.map(item => `${item.title}: ${item.summary}`))}`,
  ].join('\n')
}

function serializeContext(items: string[]) {
  if (items.length === 0) return 'none'
  return items.map(item => `- ${item}`).join('\n')
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

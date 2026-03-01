// ◼︎ DOJO Web — /api/chat
// Streams NIAMA responses from Mac Studio DOJO :7410
// Never exposes chamber URLs to the browser.

import { type NextRequest } from 'next/server'
import { chamberUrl } from '@/lib/chambers'

export const runtime = 'nodejs'

export async function POST(req: NextRequest) {
  const { message, history, conversationId } = await req.json()

  // Attempt to reach DOJO on Mac Studio
  try {
    const dojoRes = await fetch(`${chamberUrl('dojo')}/chat/stream`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message, history, conversationId }),
    })

    if (!dojoRes.ok || !dojoRes.body) throw new Error(`DOJO HTTP ${dojoRes.status}`)

    // Pass DOJO's stream straight through
    return new Response(dojoRes.body, {
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'X-Accel-Buffering': 'no',
      },
    })
  } catch {
    // DOJO offline — return graceful degraded response
    const fallback = degradedStream(message)
    return new Response(fallback, {
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
      },
    })
  }
}

// Solo mode — DOJO offline, acknowledge and guide
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

      function tick() {
        if (i >= words.length) {
          controller.enqueue(encoder.encode('data: {"done":true}\n\n'))
          controller.close()
          return
        }
        const chunk = words.slice(i, i + 3).join(' ') + ' '
        controller.enqueue(encoder.encode(`data: ${JSON.stringify({ content: chunk })}\n\n`))
        i += 3
        setTimeout(tick, 30)
      }
      tick()
    },
  })
}

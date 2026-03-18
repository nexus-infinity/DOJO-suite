// ◼︎ DOJO Web — /api/mcp
// Proxies MCP tool calls to the appropriate FIELD chamber.
// Keeps chamber endpoints server-side only.

import { type NextRequest, NextResponse } from 'next/server'
import { FIELD_MCP_SERVICES } from '@/lib/mcpServices'
import { chamberUrl, type ChamberKey } from '@/lib/chambers'

interface MCPToolRequest {
  service: string    // e.g. 'notion'
  tool: string       // e.g. 'search_pages'
  args: Record<string, unknown>
}

export async function POST(req: NextRequest) {
  const body: MCPToolRequest = await req.json()
  const { service, tool, args } = body

  const svc = FIELD_MCP_SERVICES.find(s => s.id === service)
  if (!svc) {
    return NextResponse.json({ error: `Unknown service: ${service}` }, { status: 400 })
  }

  if (!svc.clientExposed) {
    return NextResponse.json({
      error: 'Service folded through sacred chamber routing',
      service,
      tool,
      via: chamberUrl(svc.chamber as ChamberKey),
      directPort: svc.directPort ?? null,
      detail: 'This Vercel/web surface treats Tier 2 as a capability routed by the chamber, not as a direct client HTTP endpoint.',
    }, { status: 501 })
  }

  const base = svc.directPort
    ? `${chamberUrl(svc.chamber as ChamberKey).replace(/:\d+$/, '')}:${svc.directPort}`
    : chamberUrl(svc.chamber as ChamberKey)

  try {
    const res = await fetch(`${base}/mcp/tools/call`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: tool,
        tool,
        arguments: args,
      }),
    })
    if (!res.ok) throw new Error(`HTTP ${res.status}`)
    return NextResponse.json(await res.json())
  } catch (err) {
    return NextResponse.json({
      error: 'Chamber unreachable',
      service,
      tool,
      detail: err instanceof Error ? err.message : 'unknown',
    }, { status: 502 })
  }
}

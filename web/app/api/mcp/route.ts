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

  const base = svc.port > 0
    ? `${chamberUrl(svc.chamber as ChamberKey).replace(/:\d+$/, '')}:${svc.port}`
    : chamberUrl(svc.chamber as ChamberKey)

  try {
    const res = await fetch(`${base}/mcp/tool/${tool}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(args),
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

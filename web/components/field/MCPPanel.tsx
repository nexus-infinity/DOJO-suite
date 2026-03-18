'use client'

import { ALL_MCP_SERVICES, FIELD_MCP_SERVICES, THIRD_PARTY_MCP_SERVICES, type MCPService } from '@/lib/mcpServices'
import { CHAMBERS } from '@/lib/chambers'
import { SpellCircle } from './SpellCircle'
import { useEffect, useMemo, useState } from 'react'

interface Props { onClose: () => void }
interface ServiceStatus {
  id: string
  status: 'connected' | 'routed' | 'unreachable' | 'unverified'
  chamberReachable: boolean
  gatewayReachable: boolean | null
  directPort: number | null
  detail: string
}

export function MCPPanel({ onClose }: Props) {
  const [expandedId, setExpandedId] = useState<string | null>(null)
  const [statuses, setStatuses] = useState<Record<string, ServiceStatus>>({})

  useEffect(() => {
    let cancelled = false

    async function loadStatuses() {
      try {
        const res = await fetch('/api/mcp/status', { cache: 'no-store' })
        if (!res.ok) throw new Error(`HTTP ${res.status}`)
        const json = await res.json()
        if (cancelled) return
        setStatuses(Object.fromEntries((json.services as ServiceStatus[]).map(service => [service.id, service])))
      } catch {
        if (!cancelled) setStatuses({})
      }
    }

    loadStatuses()
    const interval = window.setInterval(loadStatuses, 15_000)
    return () => {
      cancelled = true
      window.clearInterval(interval)
    }
  }, [])

  const activeRoutes = useMemo(
    () => Object.values(statuses).filter(status => status.status === 'connected' || status.status === 'routed').length,
    [statuses]
  )

  return (
    <aside className="w-80 shrink-0 border-l border-border bg-surface flex flex-col overflow-hidden">

      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3 border-b border-border">
        <div>
          <h2 className="text-sm font-semibold text-slate-200">MCP Connections</h2>
          <p className="text-xs text-muted mt-0.5">{activeRoutes} active routes · {ALL_MCP_SERVICES.length} listed</p>
        </div>
        <button onClick={onClose} className="text-muted hover:text-slate-300 text-lg leading-none">×</button>
      </div>

      <div className="flex-1 overflow-y-auto">

        {/* FIELD Tier 2 */}
        <div className="p-3">
          <div className="flex items-center gap-2 px-1 mb-2">
            <span className="text-xs font-semibold text-muted uppercase tracking-wider">FIELD Tier 2</span>
            <span className="text-xs text-arkadas bg-arkadas/10 px-1.5 rounded font-mono">◉ internal</span>
          </div>
          <p className="px-1 pb-2 text-xs text-dim leading-relaxed">
            Routed through sacred chambers. Status is read-only and derived from live routing/gateway probes, not UI toggles.
          </p>
          <div className="space-y-1.5">
            {FIELD_MCP_SERVICES.map(svc => (
              <ServiceRow key={svc.id} svc={svc} status={statuses[svc.id]}
                expanded={expandedId === svc.id}
                onExpand={() => setExpandedId(expandedId === svc.id ? null : svc.id)}
              />
            ))}
          </div>
        </div>

        <div className="border-t border-border mx-3" />

        {/* Third-party */}
        <div className="p-3">
          <div className="flex items-center gap-2 px-1 mb-2">
            <span className="text-xs font-semibold text-muted uppercase tracking-wider">Third-party</span>
            <span className="text-xs text-atlas bg-atlas/10 px-1.5 rounded font-mono">▲ external</span>
          </div>
          <div className="space-y-1.5">
            {THIRD_PARTY_MCP_SERVICES.map(svc => (
              <ServiceRow key={svc.id} svc={svc} status={statuses[svc.id]}
                expanded={expandedId === svc.id}
                onExpand={() => setExpandedId(expandedId === svc.id ? null : svc.id)}
              />
            ))}
          </div>
        </div>

        <div className="border-t border-border mx-3" />

        {/* Add custom MCP */}
        <div className="p-3">
          <div className="w-full flex items-center gap-2 px-3 py-2.5 rounded-lg border border-dashed border-border text-muted text-xs">
            <span className="text-base">+</span>
            <span>Custom MCP registration not yet wired on this surface</span>
          </div>
          <p className="text-xs text-dim mt-2 px-1 leading-relaxed">
            This panel currently reports live status only. Registration flow should be added only when it can write to canonical FIELD config.
          </p>
        </div>
      </div>

      {/* Footer — routing legend */}
      <div className="border-t border-border p-3">
        <p className="text-xs text-dim font-mono mb-1.5">Chamber routing</p>
        <div className="grid grid-cols-2 gap-1">
          {(['dojo', 'obiwan', 'atlas', 'tata', 'akron'] as const).map(ch => (
            <div key={ch} className="flex items-center gap-1.5">
              <SpellCircle chamber={ch} size={12} compact />
              <span className="text-xs text-dim">:{CHAMBERS[ch].port}</span>
            </div>
          ))}
        </div>
      </div>
    </aside>
  )
}

function ServiceRow({ svc, status, expanded, onExpand }: {
  svc: MCPService
  status?: ServiceStatus
  expanded: boolean
  onExpand: () => void
}) {
  const chamberColor = CHAMBERS[svc.chamber as keyof typeof CHAMBERS]?.color ?? '#64748B'
  const statusValue = status?.status ?? 'unverified'
  const statusLabel = statusValue === 'connected'
    ? 'Connected'
    : statusValue === 'routed'
    ? 'Routed'
    : statusValue === 'unreachable'
    ? 'Offline'
    : 'Unverified'
  const statusClass = statusValue === 'connected'
    ? 'text-green-300 bg-green-500/10 border-green-500/20'
    : statusValue === 'routed'
    ? 'text-amber-300 bg-amber-500/10 border-amber-500/20'
    : statusValue === 'unreachable'
    ? 'text-red-300 bg-red-500/10 border-red-500/20'
    : 'text-slate-300 bg-slate-500/10 border-slate-500/20'

  return (
    <div className={`rounded-lg border transition-all ${
      statusValue === 'unreachable' ? 'border-border/50 bg-surface opacity-75' : 'border-border bg-raised'
    }`}>
      <div className="flex items-center gap-2.5 px-3 py-2">
        {/* Service icon */}
        <div className="w-7 h-7 rounded-md flex items-center justify-center text-xs font-bold shrink-0"
          style={{ background: `${chamberColor}18`, color: chamberColor, border: `1px solid ${chamberColor}30` }}>
          {svc.symbol.length > 2 ? svc.symbol.slice(0,2) : svc.symbol}
        </div>

        {/* Name + description */}
        <div className="flex-1 min-w-0" onClick={onExpand} role="button">
          <div className="text-sm text-slate-200 font-medium">{svc.name}</div>
          <div className="text-xs text-muted truncate">{svc.description}</div>
        </div>

        <span className={`shrink-0 rounded-full border px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider ${statusClass}`}>
          {statusLabel}
        </span>
      </div>

      {/* Expanded detail */}
      {expanded && (
        <div className="px-3 pb-2.5 pt-0 border-t border-border/50 mt-1">
          <div className="flex flex-wrap gap-2 text-xs font-mono text-dim mt-2">
            <span>via {CHAMBERS[svc.chamber as keyof typeof CHAMBERS]?.symbol} {svc.chamber}</span>
            {status?.directPort && <span>gateway :{status.directPort}</span>}
            {svc.authType !== 'none' && <span className="text-tata">auth: {svc.authType}</span>}
          </div>
          {svc.routingNote && (
            <p className="mt-2 text-xs text-dim leading-relaxed">{svc.routingNote}</p>
          )}
          <p className="mt-2 text-xs text-slate-300 leading-relaxed">
            {status?.detail ?? 'No live status payload yet.'}
          </p>
        </div>
      )}
    </div>
  )
}

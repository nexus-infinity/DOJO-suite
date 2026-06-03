'use client'

// ◎ Kings-Chamber — Sovereign Financial Dashboard
// Market · Ledger · Friction — three panels, one surface.
// Decision-support only: live data + sovereign structure. Not an automated bot.

import { useCallback, useEffect, useState } from 'react'

// ── Types ─────────────────────────────────────────────────────────────────────

interface Ticker {
  symbol: string
  last: number
  change24h: number
  volume24h: number
  high24h: number
  low24h: number
  error?: boolean
}

interface Trade {
  id: number
  tx_id: string
  tata_sequence_id: number
  tata_previous_hash: string
  symbol: string
  direction: string
  quantity: number
  from_node: string
  to_node: string
  status: string
  blockchain_tx_hash?: string
  recorded_at: string
}

interface FrictionEntry {
  id: string
  label: string
  target_system: string
  severity: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL'
  prediction: string
  constraints: string[]
  observations: string[]
  intervention: Record<string, string>
  status: 'open' | 'resolved'
  opened_at: string
}

interface DashData {
  timestamp: string
  market: Ticker[]
  ledger: { trades: Trade[]; chain_tip: string; total?: number; note?: string }
  friction: { active: FrictionEntry[]; resolved: FrictionEntry[] }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

const SYMBOL_LABELS: Record<string, { base: string; color: string }> = {
  BTC_USDT: { base: 'BTC', color: '#F59E0B' },
  ETH_USDT: { base: 'ETH', color: '#06B6D4' },
  SOL_USDT: { base: 'SOL', color: '#8B5CF6' },
  BNB_USDT: { base: 'BNB', color: '#EAB308' },
}

const SEVERITY_COLORS: Record<string, string> = {
  LOW: '#22C55E',
  MEDIUM: '#F59E0B',
  HIGH: '#EF4444',
  CRITICAL: '#F43F5E',
}

function fmt(n: number, decimals = 2) {
  if (!n) return '—'
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`
  if (n >= 1_000) return `${(n / 1_000).toFixed(1)}K`
  return n.toFixed(decimals)
}

function fmtPrice(n: number) {
  if (!n) return '—'
  return n.toLocaleString('en-AU', { style: 'currency', currency: 'USD', minimumFractionDigits: 2 })
}

// ── Ticker Card ───────────────────────────────────────────────────────────────

function TickerCard({ t }: { t: Ticker }) {
  const meta = SYMBOL_LABELS[t.symbol] ?? { base: t.symbol.split('_')[0], color: '#64748B' }
  const up = t.change24h >= 0
  return (
    <div className="rounded-lg border border-border bg-raised p-4 flex flex-col gap-2">
      <div className="flex items-center justify-between">
        <span className="font-mono font-bold text-sm" style={{ color: meta.color }}>{meta.base}</span>
        <span className={`text-xs font-mono px-2 py-0.5 rounded ${up ? 'bg-green-950 text-green-400' : 'bg-red-950 text-red-400'}`}>
          {up ? '+' : ''}{t.change24h}%
        </span>
      </div>
      <div className="font-mono text-xl font-bold text-white">
        {t.error ? <span className="text-muted text-sm">offline</span> : fmtPrice(t.last)}
      </div>
      <div className="flex justify-between text-xs text-muted font-mono">
        <span>H {fmtPrice(t.high24h)}</span>
        <span>L {fmtPrice(t.low24h)}</span>
        <span>Vol {fmt(t.volume24h, 0)}</span>
      </div>
    </div>
  )
}

// ── Trade Row ─────────────────────────────────────────────────────────────────

function TradeRow({ trade }: { trade: Trade }) {
  const isBuy = trade.direction === 'buy'
  return (
    <div className="flex items-center gap-3 py-2 border-b border-border text-xs font-mono">
      <span className="text-muted w-6 text-right">#{trade.tata_sequence_id}</span>
      <span className={`w-10 text-center px-1 rounded ${isBuy ? 'bg-green-950 text-green-400' : 'bg-red-950 text-red-400'}`}>
        {trade.direction.toUpperCase()}
      </span>
      <span className="text-atlas w-20">{trade.symbol?.split('_')[0] ?? '—'}</span>
      <span className="text-white">{trade.quantity}</span>
      <span className="text-muted flex-1 truncate">{trade.from_node} → {trade.to_node}</span>
      <span className={`px-1 rounded ${trade.status === 'Completed' ? 'text-green-400' : trade.status === 'Failed' ? 'text-red-400' : 'text-tata'}`}>
        {trade.status}
      </span>
    </div>
  )
}

// ── Friction Card ─────────────────────────────────────────────────────────────

function FrictionCard({ f }: { f: FrictionEntry }) {
  const [expanded, setExpanded] = useState(false)
  const color = SEVERITY_COLORS[f.severity] ?? '#64748B'
  return (
    <div className="rounded-lg border bg-raised p-4 flex flex-col gap-3" style={{ borderColor: color + '40' }}>
      <div className="flex items-start justify-between gap-2">
        <div>
          <div className="flex items-center gap-2">
            <span className="font-mono font-bold text-sm" style={{ color }}>{f.target_system}</span>
            <span className="text-xs px-2 py-0.5 rounded font-mono" style={{ background: color + '20', color }}>
              {f.severity}
            </span>
          </div>
          <div className="text-xs text-muted font-mono mt-0.5">{f.label}</div>
        </div>
        <button
          onClick={() => setExpanded(e => !e)}
          className="text-muted text-xs hover:text-white transition-colors mt-0.5"
        >
          {expanded ? '▲ less' : '▼ more'}
        </button>
      </div>

      <div className="text-xs text-white/70 leading-relaxed">{f.prediction}</div>

      {expanded && (
        <div className="flex flex-col gap-3 pt-2 border-t border-border">
          <div>
            <div className="text-xs text-atlas font-mono mb-1">Constraints</div>
            <div className="flex flex-wrap gap-1">
              {f.constraints.map(c => (
                <span key={c} className="text-xs bg-surface px-2 py-0.5 rounded text-muted font-mono">{c}</span>
              ))}
            </div>
          </div>
          <div>
            <div className="text-xs text-tata font-mono mb-1">Observations</div>
            <div className="flex flex-col gap-0.5">
              {f.observations.map(o => (
                <div key={o} className="text-xs text-white/60 font-mono">→ {o}</div>
              ))}
            </div>
          </div>
          <div>
            <div className="text-xs text-kings font-mono mb-1">Intervention — single packet</div>
            <div className="bg-void rounded p-3 flex flex-col gap-1.5">
              {Object.entries(f.intervention).map(([k, v]) => (
                <div key={k} className="text-xs font-mono">
                  <span className="text-muted">{k.replace(/_/g, ' ')}: </span>
                  <span className="text-white/80">{v}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

// ── Main Dashboard ────────────────────────────────────────────────────────────

type Tab = 'market' | 'ledger' | 'friction'

export function SovereignDashboard() {
  const [tab, setTab] = useState<Tab>('market')
  const [data, setData] = useState<DashData | null>(null)
  const [loading, setLoading] = useState(true)
  const [lastUpdate, setLastUpdate] = useState<string | null>(null)

  const load = useCallback(async () => {
    try {
      const res = await fetch('/api/sovereign')
      if (res.ok) {
        const d = await res.json() as DashData
        setData(d)
        setLastUpdate(new Date(d.timestamp).toLocaleTimeString('en-AU'))
      }
    } catch { /* silent — will retry */ }
    finally { setLoading(false) }
  }, [])

  useEffect(() => {
    load()
    const interval = setInterval(load, 30_000)  // refresh every 30s
    return () => clearInterval(interval)
  }, [load])

  const tabs: { id: Tab; label: string; count?: number }[] = [
    { id: 'market', label: 'Market', count: data?.market.length },
    { id: 'ledger', label: 'Ledger', count: data?.ledger.trades?.length },
    { id: 'friction', label: 'Friction', count: data?.friction.active?.length },
  ]

  return (
    <div className="flex flex-col h-full bg-void text-white font-sans">
      {/* Header */}
      <div className="flex items-center justify-between px-6 py-4 border-b border-border">
        <div className="flex items-center gap-3">
          <div className="w-2 h-2 rounded-full bg-kings animate-pulse-glow" />
          <span className="font-mono text-sm text-kings font-bold tracking-wider">KINGS-CHAMBER</span>
          <span className="text-muted text-xs font-mono">852 Hz · sovereign financial</span>
        </div>
        <div className="flex items-center gap-3">
          {lastUpdate && (
            <span className="text-muted text-xs font-mono">updated {lastUpdate}</span>
          )}
          <button
            onClick={load}
            className="text-xs text-muted hover:text-white font-mono transition-colors px-2 py-1 rounded border border-border hover:border-kings"
          >
            ↻ refresh
          </button>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex border-b border-border px-6">
        {tabs.map(t => (
          <button
            key={t.id}
            onClick={() => setTab(t.id)}
            className={`px-4 py-3 text-sm font-mono border-b-2 transition-colors ${
              tab === t.id
                ? 'border-kings text-white'
                : 'border-transparent text-muted hover:text-white'
            }`}
          >
            {t.label}
            {t.count !== undefined && (
              <span className="ml-2 text-xs bg-raised px-1.5 py-0.5 rounded text-muted">{t.count}</span>
            )}
          </button>
        ))}
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto p-6">
        {loading && (
          <div className="flex items-center justify-center h-32 text-muted font-mono text-sm">
            <div className="w-4 h-4 border-2 border-kings border-t-transparent rounded-full animate-spin mr-3" />
            loading sovereign data…
          </div>
        )}

        {!loading && data && (
          <>
            {/* ── Market tab ── */}
            {tab === 'market' && (
              <div className="flex flex-col gap-6">
                <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
                  {data.market.map(t => <TickerCard key={t.symbol} t={t} />)}
                </div>
                <div className="rounded-lg border border-border bg-raised p-4">
                  <div className="text-xs font-mono text-muted mb-3">Decision-support note</div>
                  <p className="text-xs text-white/60 leading-relaxed font-mono">
                    Live prices via Crypto.com public API · 30s refresh ·
                    Trades executed through Kings-Chamber invocation surface (port 8520) ·
                    Each trade issues a TataAnchor before DOJO executes ·
                    This dashboard is decision-support — not automated trading.
                  </p>
                </div>
              </div>
            )}

            {/* ── Ledger tab ── */}
            {tab === 'ledger' && (
              <div className="flex flex-col gap-4">
                <div className="flex items-center justify-between">
                  <div className="text-xs font-mono text-muted">
                    Chain tip: <span className="text-atlas">{data.ledger.chain_tip ?? '—'}</span>
                  </div>
                  <div className="text-xs font-mono text-muted">
                    {data.ledger.total ?? data.ledger.trades?.length ?? 0} trades recorded
                  </div>
                </div>
                {data.ledger.note && (
                  <div className="rounded-lg border border-border bg-raised p-4 text-xs text-muted font-mono">
                    {data.ledger.note}
                  </div>
                )}
                <div className="rounded-lg border border-border bg-raised overflow-hidden">
                  <div className="flex items-center gap-3 px-3 py-2 border-b border-border text-xs font-mono text-muted">
                    <span className="w-6">#</span>
                    <span className="w-10">DIR</span>
                    <span className="w-20">ASSET</span>
                    <span>QTY</span>
                    <span className="flex-1">ROUTE</span>
                    <span>STATUS</span>
                  </div>
                  {data.ledger.trades?.length === 0 ? (
                    <div className="p-6 text-center text-xs text-muted font-mono">
                      No trades yet · use <span className="text-kings">kingschamber_trade_sequence</span> to execute your first sovereign trade
                    </div>
                  ) : (
                    <div className="px-3">
                      {data.ledger.trades.map(t => <TradeRow key={t.tx_id} trade={t} />)}
                    </div>
                  )}
                </div>
              </div>
            )}

            {/* ── Friction tab ── */}
            {tab === 'friction' && (
              <div className="flex flex-col gap-4">
                <div className="text-xs font-mono text-muted">
                  {data.friction.active.length} active · {data.friction.resolved.length} resolved
                  <span className="ml-3 text-white/40">· C-M-O-F constraint-alignment framework</span>
                </div>
                {data.friction.active.map(f => <FrictionCard key={f.id} f={f} />)}
                {data.friction.resolved.length > 0 && (
                  <div className="mt-4">
                    <div className="text-xs font-mono text-muted mb-2">Resolved</div>
                    {data.friction.resolved.map(f => (
                      <div key={f.id} className="text-xs text-muted font-mono py-1 border-b border-border">
                        ✓ {f.target_system} — {f.label}
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}
          </>
        )}
      </div>
    </div>
  )
}

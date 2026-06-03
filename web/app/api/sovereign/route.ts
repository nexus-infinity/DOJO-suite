// ◎ Kings-Chamber — /api/sovereign
// Sovereign financial dashboard data endpoint.
// Returns: live crypto market tickers + Kings-Chamber trade ledger + active friction diagnoses.

import { readFile } from 'node:fs/promises'
import { type NextRequest, NextResponse } from 'next/server'

export const dynamic = 'force-dynamic'

const CRYPTO_API = 'https://api.crypto.com/exchange/v1/public'
const SYMBOLS = ['BTC_USDT', 'ETH_USDT', 'SOL_USDT', 'BNB_USDT']

// ── Live market data from Crypto.com public REST ──────────────────────────────
async function fetchMarket() {
  try {
    const res = await fetch(`${CRYPTO_API}/get-tickers`, {
      next: { revalidate: 30 },
      signal: AbortSignal.timeout(5000),
    })
    if (!res.ok) throw new Error(`Crypto.com ${res.status}`)
    const json = await res.json()
    const tickers = (json?.result?.data ?? []) as Record<string, unknown>[]
    return SYMBOLS.map(sym => {
      const t = tickers.find(d => d.i === sym) ?? {}
      const last = Number(t.a ?? 0)
      const open24 = Number(t.oi ?? 0)
      const change24 = open24 > 0 ? ((last - open24) / open24) * 100 : 0
      return {
        symbol: sym,
        last,
        change24h: Number(change24.toFixed(2)),
        volume24h: Number(t.v ?? 0),
        high24h: Number(t.h ?? 0),
        low24h: Number(t.l ?? 0),
      }
    })
  } catch {
    return SYMBOLS.map(sym => ({ symbol: sym, last: 0, change24h: 0, volume24h: 0, high24h: 0, low24h: 0, error: true }))
  }
}

// ── Kings-Chamber trade ledger (SQLite via file) ──────────────────────────────
async function fetchLedger() {
  // Trade ledger is written by the Kings-Chamber MCP to SQLite.
  // We read recent trades from a JSON export if the SQLite driver isn't available.
  // The ledger lives at: ~/◎memorycore/databases/kingschamber_state.db
  // For the web API we read a companion JSON export that the MCP writes on each trade.
  const candidates = [
    '/Users/field/◎memorycore/databases/kingschamber_trade_ledger.json',
    '/Users/field/◎Kings-Chamber/◎trainingdata/trade_ledger_export.json',
  ]
  for (const p of candidates) {
    try {
      const raw = await readFile(p, 'utf8')
      return JSON.parse(raw)
    } catch { continue }
  }
  // Return a seeded example if no live ledger exists yet
  return {
    trades: [],
    chain_tip: 'awaiting_first_trade',
    total: 0,
    note: 'Trade ledger empty — execute first trade via kingschamber_trade_sequence tool',
  }
}

// ── Active friction diagnoses (C-M-O-F) ─────────────────────────────────────
async function fetchFriction() {
  const candidates = [
    '/Users/field/◎Kings-Chamber/friction_registry.json',
    '/Users/field/◼︎DOJO/friction_registry.json',
  ]
  for (const p of candidates) {
    try {
      const raw = await readFile(p, 'utf8')
      return JSON.parse(raw)
    } catch { continue }
  }
  // Seed with the NAB scenario as default example
  return {
    active: [
      {
        id: 'F-NAB-001',
        label: 'Misalignment_With_Constraint',
        target_system: 'NAB',
        severity: 'HIGH',
        prediction: 'System will not self-resolve. Only constraint alignment unlocks flow.',
        constraints: ['Regulatory_Geometry', 'Identity_Integrity', 'Risk_Minimisation'],
        observations: ['Account locked / restricted', 'No proactive follow-up', 'Requests for identity / source-of-funds'],
        intervention: {
          identity_document: 'Passport + drivers licence — unambiguous, current',
          source_of_funds: 'Traceable chain: employment income + investment returns + property sale',
          timeline: 'Chronological, clean — no gaps, no narrative, dates + amounts only',
        },
        status: 'open',
        opened_at: new Date().toISOString(),
      },
    ],
    resolved: [],
  }
}

export async function GET(_req: NextRequest) {
  const [market, ledger, friction] = await Promise.allSettled([
    fetchMarket(),
    fetchLedger(),
    fetchFriction(),
  ])

  return NextResponse.json({
    timestamp: new Date().toISOString(),
    market: market.status === 'fulfilled' ? market.value : [],
    ledger: ledger.status === 'fulfilled' ? ledger.value : { trades: [], chain_tip: 'error' },
    friction: friction.status === 'fulfilled' ? friction.value : { active: [], resolved: [] },
  })
}

// FIELD — /comms
// Active correspondence reference surface.
// Reference structure only — no case details, no evidence.

import Link from 'next/link'

export const metadata = {
  title: 'FIELD / Comms',
  description: 'Active correspondence lanes — FIELD sovereign reference surface',
}

// Triangle check state types
type CheckState = 'confirmed' | 'pending' | 'absent'

interface TriangleCheck {
  fact: CheckState
  document: CheckState
  ledger: CheckState
}

interface Lane {
  ref: string
  subject: string
  status: 'PENDING' | 'ACTIVE' | 'AWAITING' | 'FILED'
  nextMove: string
  triangle: TriangleCheck
  color: string
}

const LANES: Lane[] = [
  {
    ref: 'FIELD-HF-20260422-001',
    subject: 'H200/A100 platform complaint — HuggingFace training infrastructure',
    status: 'PENDING',
    nextMove: 'Await HuggingFace infrastructure team response. Escalate at T+5 business days.',
    triangle: { fact: 'confirmed', document: 'pending', ledger: 'pending' },
    color: '#9370DB',
  },
  {
    ref: 'FIELD-LEGAL-OB1-2022-001',
    subject: 'OB1Link / Swiss bank — A$465,000 funds recovery',
    status: 'ACTIVE',
    nextMove: 'Confirm recipient identity and ING transfer receipt. Submit AFCA complaint amendment.',
    triangle: { fact: 'confirmed', document: 'pending', ledger: 'pending' },
    color: '#FFD700',
  },
  {
    ref: 'FIELD-LEGAL-PRIME-2022-001',
    subject: 'Prime / 10 Watts Parade — property dispute',
    status: 'AWAITING',
    nextMove: 'Await opposing counsel response to final position letter.',
    triangle: { fact: 'confirmed', document: 'confirmed', ledger: 'pending' },
    color: '#FF8C00',
  },
  {
    ref: 'FIELD-LEGAL-PULSE-2024-001',
    subject: 'PULSE — regulatory enforcement matter',
    status: 'ACTIVE',
    nextMove: 'Prepare evidence bundle for submission. Coordinate with Agriculture Victoria timeline.',
    triangle: { fact: 'confirmed', document: 'pending', ledger: 'absent' },
    color: '#4488ff',
  },
]

const STATUS_COLOR: Record<Lane['status'], string> = {
  PENDING: '#FF8C00',
  ACTIVE: '#00CC66',
  AWAITING: '#9370DB',
  FILED: '#64748b',
}

const CHECK_SYMBOL: Record<CheckState, string> = {
  confirmed: '✔',
  pending: '⚠',
  absent: '✗',
}

const CHECK_COLOR: Record<CheckState, string> = {
  confirmed: '#00CC66',
  pending: '#FF8C00',
  absent: '#CC0000',
}

export default function CommsPage() {
  return (
    <div className="min-h-screen bg-[#0a0a0a] text-[#f5f5f0]">
      {/* Header */}
      <header className="border-b border-[#1a1a1a] px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link
            href="/"
            className="text-[#f5f5f0] opacity-30 text-xs tracking-widest hover:opacity-50 transition-opacity uppercase"
            style={{ fontFamily: 'ui-monospace, monospace' }}
          >
            ← FIELD
          </Link>
          <span className="text-[#1a1a1a] opacity-30">|</span>
          <span
            className="text-[#f5f5f0] opacity-60 text-xs tracking-widest uppercase"
            style={{ fontFamily: 'ui-monospace, monospace' }}
          >
            Comms
          </span>
        </div>
        <Link
          href="/status"
          className="text-[#f5f5f0] opacity-20 text-xs tracking-widest hover:opacity-40 transition-opacity uppercase"
          style={{ fontFamily: 'ui-monospace, monospace' }}
        >
          Status →
        </Link>
      </header>

      {/* Content */}
      <main className="max-w-4xl mx-auto px-6 py-16">
        {/* Page heading */}
        <div className="mb-16">
          <h1
            className="text-2xl font-light tracking-[0.2em] text-[#f5f5f0] opacity-80 mb-3"
            style={{ fontFamily: 'ui-sans-serif, system-ui, sans-serif' }}
          >
            Active Lanes
          </h1>
          <p
            className="text-xs text-[#f5f5f0] opacity-30 tracking-wider"
            style={{ fontFamily: 'ui-monospace, monospace' }}
          >
            Reference structure only — {LANES.length} active correspondence lanes
          </p>
        </div>

        {/* Lanes */}
        <div className="flex flex-col gap-8">
          {LANES.map((lane) => (
            <LaneCard key={lane.ref} lane={lane} />
          ))}
        </div>

        {/* Observer contract */}
        <div className="mt-24 pt-12 border-t border-[#1a1a1a]">
          <p
            className="text-xs text-[#f5f5f0] opacity-20 tracking-wider leading-relaxed max-w-2xl"
            style={{ fontFamily: 'ui-monospace, monospace' }}
          >
            OBSERVER CONTRACT — This surface is read-only. Reference numbers are canonical identifiers
            for correspondence tracking. No case materials, evidence, or legal strategy is published here.
            All active matters are governed by the FIELD sovereign framework.
            Contact: jeremy.rich@berjak.com.au
          </p>
        </div>
      </main>
    </div>
  )
}

function LaneCard({ lane }: { lane: Lane }) {
  return (
    <div
      className="border border-[#1a1a1a] p-6 hover:border-[#2a2a2a] transition-colors"
      style={{ borderLeftColor: `${lane.color}22`, borderLeftWidth: '2px' }}
    >
      {/* Ref + status row */}
      <div className="flex items-start justify-between gap-4 mb-4">
        <span
          className="text-xs tracking-widest text-[#f5f5f0] opacity-50"
          style={{ fontFamily: 'ui-monospace, monospace' }}
        >
          {lane.ref}
        </span>
        <span
          className="text-[10px] tracking-widest px-2 py-0.5 shrink-0"
          style={{
            color: STATUS_COLOR[lane.status],
            border: `1px solid ${STATUS_COLOR[lane.status]}44`,
            fontFamily: 'ui-monospace, monospace',
          }}
        >
          {lane.status}
        </span>
      </div>

      {/* Subject */}
      <h2
        className="text-sm text-[#f5f5f0] opacity-75 mb-4 leading-relaxed"
        style={{ fontFamily: 'ui-sans-serif, system-ui, sans-serif' }}
      >
        {lane.subject}
      </h2>

      {/* Triangle check */}
      <div className="flex gap-6 mb-4">
        <TriangleItem label="Fact" state={lane.triangle.fact} />
        <TriangleItem label="Document" state={lane.triangle.document} />
        <TriangleItem label="Ledger" state={lane.triangle.ledger} />
      </div>

      {/* Next move */}
      <p
        className="text-xs text-[#f5f5f0] opacity-35 leading-relaxed border-t border-[#1a1a1a] pt-4 mt-4"
        style={{ fontFamily: 'ui-monospace, monospace' }}
      >
        → {lane.nextMove}
      </p>
    </div>
  )
}

function TriangleItem({ label, state }: { label: string; state: CheckState }) {
  return (
    <div className="flex items-center gap-1.5">
      <span
        className="text-xs"
        style={{ color: CHECK_COLOR[state], fontFamily: 'ui-monospace, monospace' }}
      >
        {CHECK_SYMBOL[state]}
      </span>
      <span
        className="text-[10px] tracking-wider"
        style={{ color: '#f5f5f0', opacity: 0.3, fontFamily: 'ui-monospace, monospace' }}
      >
        {label}
      </span>
    </div>
  )
}

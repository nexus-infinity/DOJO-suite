// ◼︎ DOJO Web — SpellCircle component
// SVG translation of FieldSpellCircle.swift
// Spoke counts per chamber frequency (Doctor Strange / Ditko aesthetic)

import React from 'react'
import { CHAMBERS, type ChamberKey } from '@/lib/chambers'

const SPOKE_COUNTS: Record<ChamberKey, number> = {
  dojo:    7,   // DOJO — prime
  obiwan:  9,   // 963 = 9 × 107
  atlas:   6,   // 528 = 6 harmonics
  tata:    4,   // 432 = 4/4 time, earth
  akron:   3,   // 396 = triangle base
  arkadas: 8,   // SPIN — 8 directions
  kings:   12,  // 852 — full clock, bridge
}

interface SpellCircleProps {
  chamber: ChamberKey
  size?: number
  active?: boolean
  compact?: boolean
  className?: string
}

export function SpellCircle({ chamber, size = 80, active = true, compact = false, className = '' }: SpellCircleProps) {
  const ch = CHAMBERS[chamber]
  const spokes = SPOKE_COUNTS[chamber]
  const cx = size / 2
  const cy = size / 2
  const outerR = size * 0.46
  const innerR = size * 0.28
  const spokeLen = outerR - innerR
  const opacity = active ? 1 : 0.3
  const color = ch.color

  const spokeAngles = Array.from({ length: spokes }, (_, i) => (360 / spokes) * i - 90)

  return (
    <svg
      width={size}
      height={size}
      viewBox={`0 0 ${size} ${size}`}
      className={className}
      aria-label={`${ch.symbol} ${ch.name} ${ch.freq} Hz`}
    >
      {/* Outer ring */}
      <circle
        cx={cx} cy={cy} r={outerR}
        fill="none"
        stroke={color}
        strokeWidth={compact ? 0.8 : 1.2}
        opacity={opacity * 0.6}
      />

      {/* Inner ring */}
      <circle
        cx={cx} cy={cy} r={innerR}
        fill="none"
        stroke={color}
        strokeWidth={compact ? 0.6 : 1}
        opacity={opacity * 0.4}
        style={{ animation: active ? 'rotate-ccw 18s linear infinite' : 'none', transformOrigin: `${cx}px ${cy}px` }}
      />

      {/* Spokes */}
      {spokeAngles.map((angle, i) => {
        const rad = (angle * Math.PI) / 180
        const x1 = cx + innerR * Math.cos(rad)
        const y1 = cy + innerR * Math.sin(rad)
        const x2 = cx + outerR * Math.cos(rad)
        const y2 = cy + outerR * Math.sin(rad)
        return (
          <line key={i} x1={x1} y1={y1} x2={x2} y2={y2}
            stroke={color} strokeWidth={compact ? 0.5 : 0.8} opacity={opacity * 0.7}
          />
        )
      })}

      {/* Centre symbol */}
      {!compact && (
        <text
          x={cx} y={cy}
          textAnchor="middle"
          dominantBaseline="central"
          fontSize={size * 0.22}
          fill={color}
          opacity={opacity}
          style={{ filter: active ? `drop-shadow(0 0 ${size * 0.06}px ${color})` : 'none' }}
        >
          {ch.symbol}
        </text>
      )}
    </svg>
  )
}

// BEAR coherence ring
interface BEARRingProps { score: number; size?: number; className?: string }

export function BEARRing({ score, size = 120, className = '' }: BEARRingProps) {
  const r = (size - 12) / 2
  const circumference = 2 * Math.PI * r
  const offset = circumference * (1 - Math.max(0, Math.min(1, score)))

  const color = score >= 0.9 ? '#22C55E'
              : score >= 0.75 ? '#EAB308'
              : score >= 0.5  ? '#F97316'
              : '#EF4444'

  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} className={className}>
      {/* Track */}
      <circle cx={size/2} cy={size/2} r={r}
        fill="none" stroke="#2A2A40" strokeWidth={6} />
      {/* Fill */}
      <circle cx={size/2} cy={size/2} r={r}
        fill="none" stroke={color} strokeWidth={6} strokeLinecap="round"
        strokeDasharray={circumference}
        strokeDashoffset={offset}
        transform={`rotate(-90 ${size/2} ${size/2})`}
        className="bear-fill"
        style={{ filter: `drop-shadow(0 0 6px ${color}88)` }}
      />
      {/* Labels */}
      <text x={size/2} y={size/2 - 4} textAnchor="middle" fontSize={size * 0.18}
        fill={color} fontFamily="ui-monospace, monospace" fontWeight="600">
        {(score * 100).toFixed(0)}%
      </text>
      <text x={size/2} y={size/2 + size * 0.16} textAnchor="middle" fontSize={size * 0.11}
        fill="#64748B" fontFamily="ui-monospace, monospace">
        BEAR
      </text>
    </svg>
  )
}

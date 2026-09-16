// FIELD chamber definitions — web mirror of FieldDesignSystem.swift
// Formula: PORT = FREQUENCY × 10
// Colors = Brand Kit Accent Base (GOLDEN) via lib/brandKit.ts

import { BRAND_KIT } from './brandKit'

export const CHAMBERS = {
  dojo:    { symbol: '◼︎', name: 'DOJO',          freq: 741,  port: 7410, color: BRAND_KIT.chambers.dojo,    role: 'Manifestation apex — master professor' },
  obiwan:  { symbol: '●',  name: 'OBI-WAN',        freq: 963,  port: 9630, color: BRAND_KIT.chambers.obiwan,  role: 'Observer consciousness — living memory' },
  atlas:   { symbol: '▲',  name: 'ATLAS',          freq: 528,  port: 5280, color: BRAND_KIT.chambers.atlas,   role: 'Crystalline validation — structural truth' },
  tata:    { symbol: '▼',  name: 'TATA',           freq: 432,  port: 4320, color: BRAND_KIT.chambers.tata,    role: 'Temporal truth — what actually happened' },
  akron:   { symbol: '◻',  name: 'AKRON',          freq: 396,  port: 3960, color: BRAND_KIT.chambers.akron,   role: 'Archive sovereignty — permanent record' },
  arkadas: { symbol: '◉',  name: 'ARKADAŞ',        freq: 717,  port: 7170, color: BRAND_KIT.chambers.arkadas, role: 'Embodiment bridge — homeostasis (SPIN)' },
  kings:   { symbol: '◎',  name: 'Kings Chamber',  freq: 852,  port: 8520, color: BRAND_KIT.chambers.kings,   role: 'Consciousness bridge — infrastructure' },
} as const

export type ChamberKey = keyof typeof CHAMBERS

export function chamberUrl(key: ChamberKey): string {
  const envKey = `FIELD_${key.toUpperCase()}_URL`
  // Server-side only — never expose chamber URLs client-side
  return process.env[envKey] ?? `http://localhost:${CHAMBERS[key].port}`
}

// FIELD chamber definitions — web mirror of FieldDesignSystem.swift
// Formula: PORT = FREQUENCY × 10

export const CHAMBERS = {
  dojo:    { symbol: '◼︎', name: 'DOJO',          freq: 741,  port: 7410, color: '#7C3AED', role: 'Manifestation apex — master professor' },
  obiwan:  { symbol: '●',  name: 'OBI-WAN',        freq: 963,  port: 9630, color: '#E2E8F0', role: 'Observer consciousness — living memory' },
  atlas:   { symbol: '▲',  name: 'ATLAS',          freq: 528,  port: 5280, color: '#06B6D4', role: 'Crystalline validation — structural truth' },
  tata:    { symbol: '▼',  name: 'TATA',           freq: 432,  port: 4320, color: '#F59E0B', role: 'Temporal truth — what actually happened' },
  akron:   { symbol: '◻',  name: 'AKRON',          freq: 396,  port: 3960, color: '#78716C', role: 'Archive sovereignty — permanent record' },
  arkadas: { symbol: '◉',  name: 'ARKADAŞ',        freq: 717,  port: 7170, color: '#EAB308', role: 'Embodiment bridge — homeostasis (SPIN)' },
  kings:   { symbol: '◎',  name: 'Kings Chamber',  freq: 852,  port: 8520, color: '#F43F5E', role: 'Consciousness bridge — infrastructure' },
} as const

export type ChamberKey = keyof typeof CHAMBERS

export function chamberUrl(key: ChamberKey): string {
  const envKey = `FIELD_${key.toUpperCase()}_URL`
  // Server-side only — never expose chamber URLs client-side
  return process.env[envKey] ?? `http://localhost:${CHAMBERS[key].port}`
}

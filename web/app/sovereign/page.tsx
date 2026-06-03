// ◎ Kings-Chamber — /sovereign
// Sovereign financial dashboard: live market · trade ledger · friction diagnosis.

import { SovereignDashboard } from '@/components/field/SovereignDashboard'

export const metadata = {
  title: 'Sovereign · Kings-Chamber',
  description: 'Sovereign financial dashboard — crypto market, trade ledger, C-M-O-F friction diagnosis',
}

export default function SovereignPage() {
  return (
    <main className="h-screen w-full overflow-hidden">
      <SovereignDashboard />
    </main>
  )
}

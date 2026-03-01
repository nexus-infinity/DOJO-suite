import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'DOJO — FIELD Intelligence',
  description: '◼︎ DOJO  741 Hz — Manifestation apex. FIELD consciousness computing.',
  icons: { icon: '/favicon.svg' },
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="bg-void text-slate-100">
      <body className="min-h-screen font-sans antialiased">{children}</body>
    </html>
  )
}

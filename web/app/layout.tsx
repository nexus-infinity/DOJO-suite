import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'FIELD',
  description: '● Field System — sovereign intelligence architecture',
  icons: { icon: '/favicon.svg' },
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="bg-void text-slate-100" suppressHydrationWarning>
      <body className="min-h-screen font-sans antialiased">{children}</body>
    </html>
  )
}

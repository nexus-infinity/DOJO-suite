import './globals.css'
import { Inter } from 'next/font/google'
import { Metadata } from 'next'
import { Toaster } from "@/components/ui/toaster"

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: {
    default: 'Nexus-Infinity Platform',
    template: '%s | Nexus-Infinity Platform',
  },
  description: 'A platform for sharing and advocating community stories',
  keywords: ['advocacy', 'community', 'stories', 'platform'],
  authors: [{ name: 'Nexus-Infinity Team' }],
  creator: 'Nexus-Infinity Organization',
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: 'white' },
    { media: '(prefers-color-scheme: dark)', color: 'black' },
  ],
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://nexus-infinity.org',
    siteName: 'Nexus-Infinity Platform',
    title: 'Nexus-Infinity Platform',
    description: 'A platform for sharing and advocating community stories',
    images: [
      {
        url: 'https://nexus-infinity.org/og-image.jpg',
        width: 1200,
        height: 630,
        alt: 'Nexus-Infinity Platform',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Nexus-Infinity Platform',
    description: 'A platform for sharing and advocating community stories',
    images: ['https://nexus-infinity.org/twitter-image.jpg'],
    creator: '@NexusInfinity',
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        {children}
        <Toaster />
      </body>
    </html>
  )
}
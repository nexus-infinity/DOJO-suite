import { AIFileManager } from '../../components/AIFileManager'

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <h1 className="text-4xl font-bold mb-8">Nexus-Infinity AI Engine</h1>
      <AIFileManager />
    </main>
  )
}
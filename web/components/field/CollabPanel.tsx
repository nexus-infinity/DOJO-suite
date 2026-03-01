'use client'

import { useState } from 'react'
import { SpellCircle } from './SpellCircle'

// Collaborate panel — shared project workspaces.
// Equivalent to Claude's Projects: persistent context + shared instructions.

interface Project {
  id: string
  name: string
  chamber: string
  description: string
  contextFiles: string[]
  systemPrompt: string
  updatedAt: string
}

const DEFAULT_PROJECTS: Project[] = [
  {
    id: 'niama-fracture',
    name: 'Niama Fracture Healing',
    chamber: 'dojo',
    description: 'Field Laws, Aikido, Sun Tzu, Carnegie, Counterespionage — training dataset assembly',
    contextFiles: ['NIAMA_PERSONA_INTEGRATION_SPEC.md', 'training_data_250_instances.json'],
    systemPrompt: 'You are NIAMA at 741 Hz. Evidence-first. Cat-speed execution.',
    updatedAt: '2026-03-01',
  },
  {
    id: 'response-advantage',
    name: 'Response Advantage',
    chamber: 'tata',
    description: 'S0→S7 geometric pipeline — healing through geometric accountability',
    contextFiles: ['S0-S7 pipeline', 'Recognition Engine'],
    systemPrompt: 'You are working on Response Advantage, the healing accountability platform.',
    updatedAt: '2026-02-28',
  },
  {
    id: 'berjak-fre',
    name: 'Berjak FRE',
    chamber: 'atlas',
    description: 'Commodity trading ERP — 12-point Metatron Cube GST translator',
    contextFiles: ['customer_management', 'trade_leads', 'legal_evidence'],
    systemPrompt: 'You are assisting with Berjak FRE, a professional commodity trading platform.',
    updatedAt: '2026-02-27',
  },
]

export function CollabPanel() {
  const [projects, setProjects] = useState<Project[]>(DEFAULT_PROJECTS)
  const [active, setActive] = useState<Project>(DEFAULT_PROJECTS[0])
  const [editingPrompt, setEditingPrompt] = useState(false)

  return (
    <div className="flex h-full">

      {/* Project list */}
      <div className="w-64 shrink-0 border-r border-border bg-surface flex flex-col">
        <div className="px-4 py-3 border-b border-border flex items-center justify-between">
          <h2 className="text-sm font-semibold text-slate-300">Projects</h2>
          <button className="text-xs text-dojo hover:text-dojo/80 font-mono">+ New</button>
        </div>

        <div className="flex-1 overflow-y-auto p-2 space-y-1">
          {projects.map(p => (
            <button
              key={p.id}
              onClick={() => setActive(p)}
              className={`w-full text-left px-3 py-2.5 rounded-lg transition-all ${
                active.id === p.id ? 'bg-dojo/15 border border-dojo/20' : 'hover:bg-raised'
              }`}
            >
              <div className="flex items-center gap-2 mb-1">
                <SpellCircle chamber={p.chamber as any} size={14} compact />
                <span className="text-sm font-medium text-slate-200 truncate">{p.name}</span>
              </div>
              <p className="text-xs text-muted line-clamp-2">{p.description}</p>
              <p className="text-xs text-dim mt-1">{p.updatedAt}</p>
            </button>
          ))}
        </div>
      </div>

      {/* Project detail */}
      <div className="flex-1 flex flex-col p-6 overflow-y-auto">
        <div className="flex items-start gap-4 mb-6">
          <SpellCircle chamber={active.chamber as any} size={48} />
          <div className="flex-1">
            <h1 className="text-xl font-semibold text-slate-100">{active.name}</h1>
            <p className="text-sm text-muted mt-1">{active.description}</p>
          </div>
        </div>

        {/* System prompt */}
        <section className="mb-6">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-xs font-semibold text-muted uppercase tracking-wider">System prompt</h3>
            <button
              onClick={() => setEditingPrompt(e => !e)}
              className="text-xs text-dojo hover:text-dojo/80"
            >
              {editingPrompt ? 'Save' : 'Edit'}
            </button>
          </div>
          {editingPrompt ? (
            <textarea
              defaultValue={active.systemPrompt}
              rows={4}
              className="w-full bg-raised border border-border rounded-lg p-3 text-sm text-slate-200 font-mono outline-none focus:border-dojo/40 resize-none"
            />
          ) : (
            <div className="bg-raised border border-border rounded-lg p-3 text-sm text-slate-300 font-mono">
              {active.systemPrompt}
            </div>
          )}
        </section>

        {/* Context files */}
        <section className="mb-6">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-xs font-semibold text-muted uppercase tracking-wider">Context files</h3>
            <button className="text-xs text-dojo hover:text-dojo/80">+ Add file</button>
          </div>
          <div className="space-y-1.5">
            {active.contextFiles.map(f => (
              <div key={f} className="flex items-center gap-2 px-3 py-2 bg-raised rounded-lg border border-border">
                <span className="text-dim text-xs">◻</span>
                <span className="text-sm text-slate-300 font-mono">{f}</span>
              </div>
            ))}
          </div>
        </section>

        {/* Open in chat */}
        <button className="mt-auto self-start px-4 py-2 bg-dojo/20 hover:bg-dojo/30 border border-dojo/30 text-dojo text-sm font-medium rounded-lg transition-all">
          ◈ Open in Chat
        </button>
      </div>
    </div>
  )
}

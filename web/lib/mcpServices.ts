// Tier 2 MCP service registry — web mirror of MCP/tier2_global_registry.yaml
// These route through FIELD chamber endpoints, never called directly from browser.

export interface MCPService {
  id: string
  name: string
  symbol: string
  chamber: string       // which chamber routes it
  directPort?: number
  category: 'field-tier2' | 'third-party'
  description: string
  authType: 'token' | 'oauth' | 'none'
  clientExposed?: boolean
  routingNote?: string
  status?: 'connected' | 'disconnected' | 'error'
}

export const FIELD_MCP_SERVICES: MCPService[] = [
  // FIELD Tier 2 — surfaced through sacred chambers, not directly client-exposed.
  { id: 'notion',             name: 'Notion',             symbol: 'N',  chamber: 'obiwan', directPort: 9631, category: 'field-tier2', description: 'FIELD knowledge base, Notorious Home, Chronicle', authType: 'token', clientExposed: false, routingNote: 'Folded through ● OBI-WAN sacred routing' },
  { id: 'github',             name: 'GitHub',             symbol: '⬡',  chamber: 'dojo',   directPort: 7413, category: 'field-tier2', description: 'nexus-infinity repos, issues, PRs, code search', authType: 'token', clientExposed: false, routingNote: 'Folded through ◼︎ DOJO sacred routing' },
  { id: 'huggingface',        name: 'HuggingFace',        symbol: 'H',  chamber: 'atlas',  directPort: 5281, category: 'field-tier2', description: 'misterJB datasets, model training status', authType: 'token', clientExposed: false, routingNote: 'Folded through ▲ ATLAS sacred routing' },
  { id: 'google-apps-script', name: 'Google Apps Script', symbol: 'G',  chamber: 'tata',   directPort: 4321, category: 'field-tier2', description: 'Apps Script project management through TATA', authType: 'oauth', clientExposed: false, routingNote: 'Folded through ▼ TATA sacred routing' },
  { id: 'hubspot',            name: 'HubSpot',            symbol: 'HS', chamber: 'tata',   directPort: 4322, category: 'field-tier2', description: 'CRM interface through TATA temporal truth', authType: 'token', clientExposed: false, routingNote: 'Folded through ▼ TATA sacred routing' },
  { id: 'berjak-email',       name: 'Berjak Email',       symbol: '✉',  chamber: 'dojo',   directPort: 9633, category: 'field-tier2', description: 'Sovereign email lane and legal thread control', authType: 'oauth', clientExposed: false, routingNote: 'Folded through ◼︎ DOJO sovereignty routing' },
  { id: 'comms-lane',         name: 'Comms Lane',         symbol: '∿',  chamber: 'tata',   directPort: 8521, category: 'field-tier2', description: 'Communication mediation and orchestration lane', authType: 'token', clientExposed: false, routingNote: 'Folded through ▼ TATA temporal routing' },
]

export const THIRD_PARTY_MCP_SERVICES: MCPService[] = [
  { id: 'google-drive', name: 'Google Drive',  symbol: '▲',  chamber: 'atlas',  category: 'third-party', description: 'Cloud document storage',      authType: 'oauth' },
  { id: 'gmail',        name: 'Gmail',         symbol: '✉',  chamber: 'obiwan', category: 'third-party', description: 'Email access and search',     authType: 'oauth' },
  { id: 'brave-search', name: 'Brave Search',  symbol: '🦁', chamber: 'atlas',  category: 'third-party', description: 'Web search without tracking', authType: 'token' },
  { id: 'filesystem',   name: 'Filesystem',    symbol: '◻',  chamber: 'akron',  category: 'third-party', description: 'Local file read/write',       authType: 'none'  },
]

export const ALL_MCP_SERVICES = [...FIELD_MCP_SERVICES, ...THIRD_PARTY_MCP_SERVICES]

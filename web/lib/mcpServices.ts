// Tier 2 MCP service registry — web mirror of MCP/tier2_global_registry.yaml
// These route through FIELD chamber endpoints, never called directly from browser.

export interface MCPService {
  id: string
  name: string
  symbol: string
  chamber: string       // which chamber routes it
  port: number
  category: 'field-tier2' | 'third-party'
  description: string
  authType: 'token' | 'oauth' | 'none'
  status?: 'connected' | 'disconnected' | 'error'
}

export const FIELD_MCP_SERVICES: MCPService[] = [
  // FIELD Tier 2 — internal
  { id: 'notion',       name: 'Notion',        symbol: 'N',  chamber: 'obiwan',  port: 9631, category: 'field-tier2', description: 'FIELD knowledge base, Notorious Home, Chronicle', authType: 'token' },
  { id: 'github',       name: 'GitHub',        symbol: '⬡',  chamber: 'dojo',    port: 7411, category: 'field-tier2', description: 'nexus-infinity repos, issues, PRs, code search',  authType: 'token' },
  { id: 'huggingface',  name: 'HuggingFace',   symbol: '🤗', chamber: 'atlas',   port: 5281, category: 'field-tier2', description: 'misterJB datasets, model training status',         authType: 'token' },
  { id: 'sqlite',       name: 'Memory DB',     symbol: '◎',  chamber: 'kings',   port: 8521, category: 'field-tier2', description: 'actual_state.db, requirements.db, temporal_gaps',  authType: 'none'  },
  { id: 'tata-records', name: 'TATA Records',  symbol: '▼',  chamber: 'tata',    port: 4321, category: 'field-tier2', description: 'Legal records, evidence, chronicle entries',        authType: 'none'  },
  { id: 'atlas-valid',  name: 'ATLAS Validate',symbol: '▲',  chamber: 'atlas',   port: 4322, category: 'field-tier2', description: 'Geometric validation, trident signal',             authType: 'none'  },
]

export const THIRD_PARTY_MCP_SERVICES: MCPService[] = [
  { id: 'google-drive', name: 'Google Drive',  symbol: '▲',  chamber: 'atlas',   port: 0, category: 'third-party', description: 'Cloud document storage',      authType: 'oauth' },
  { id: 'gmail',        name: 'Gmail',         symbol: '✉',  chamber: 'obiwan',  port: 0, category: 'third-party', description: 'Email access and search',     authType: 'oauth' },
  { id: 'brave-search', name: 'Brave Search',  symbol: '🦁', chamber: 'atlas',   port: 0, category: 'third-party', description: 'Web search without tracking', authType: 'token' },
  { id: 'filesystem',   name: 'Filesystem',    symbol: '◻',  chamber: 'akron',   port: 0, category: 'third-party', description: 'Local file read/write',       authType: 'none'  },
]

export const ALL_MCP_SERVICES = [...FIELD_MCP_SERVICES, ...THIRD_PARTY_MCP_SERVICES]

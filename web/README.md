# DOJO Web App

Web mirror of DOJO Suite — NIAMA conversational intelligence on the browser.

## What this is

A Claude-equivalent web interface for FIELD: **Chat**, **Code/Artifacts**, and **Collaborate** modes. Connects to Mac Studio chamber endpoints via server-side API routes. MCP panel shows all Tier 2 FIELD services (Notion, GitHub, HuggingFace, SQLite) plus third-party connectors.

## Modes

| Mode | Description |
|------|-------------|
| ◈ Chat | NIAMA conversation, streaming from DOJO :7410, solo mode if offline |
| ⟨/⟩ Code | Split artifact view — code generation + live preview |
| ⬡ Collaborate | Projects / persistent context workspaces |

## Development

```bash
cd web
npm install
npm run dev          # http://localhost:3000
```

## Environment variables (`.env.local`)

```env
FIELD_DOJO_URL=http://FIELD-Mac-Studio.local:7410
FIELD_OBIWAN_URL=http://FIELD-Mac-Studio.local:9630
FIELD_ATLAS_URL=http://FIELD-Mac-Studio.local:5280
FIELD_TATA_URL=http://FIELD-Mac-Studio.local:4320
FIELD_AKRON_URL=http://FIELD-Mac-Studio.local:3960
```

> **Note**: Chamber URLs are server-side only. Never exposed to the browser.

## Vercel deployment

1. Import `nexus-infinity/DOJO-suite` into Vercel
2. Set **Root Directory** → `web`
3. Add environment variables (chamber URLs pointing to Mac Studio)
4. Deploy — Vercel auto-detects Next.js

For local tunnel during development (so Vercel preview can reach Mac Studio):
```bash
# Option A — Cloudflare tunnel (recommended, free)
cloudflared tunnel --url http://localhost:7410

# Option B — ngrok
ngrok http 7410
# Then set FIELD_DOJO_URL=https://<ngrok-id>.ngrok.io in Vercel env vars
```

## Architecture

```
Browser
  └── Next.js (Vercel)
        ├── /api/chat    → streams from DOJO :7410
        ├── /api/health  → polls all chambers
        └── /api/mcp/*   → proxies Tier 2 MCP calls
              └── Mac Studio (FIELD-Mac-Studio.local)
                    ├── DOJO      :7410
                    ├── OBI-WAN   :9630
                    ├── ATLAS     :5280
                    ├── TATA      :4320
                    └── AKRON     :3960
```

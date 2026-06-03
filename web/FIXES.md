# DOJO Web — Production Fixes

## 2026-04-13 — Chamber URL hygiene

**Problem**: `/api/health` returning 500 with `ECONNREFUSED 100.79.35.36:9630`.
All FIELD chamber URLs in `.env.local` were set to Tailscale IPs (`100.79.35.36`).
Next.js runs on the same Mac Studio as the chambers — Tailscale IPs route to a different
network interface than what the MCP servers bind to (they bind to `127.0.0.1` only).

**Root cause**: `.env.local` was written for remote-device access (e.g. iPhone over Tailscale)
and never updated for same-machine use.

**Fixed**:
- `.env.local` — all `FIELD_*_URL` vars changed to `localhost:PORT`
- `app/api/chat/route.ts` — 3 hardcoded URLs fixed:
  1. `fetchChamberHealth()` — was `http://localhost:${port}` hardcoded, now uses `chamberUrl(key)`
  2. `fetchNotionContext()` — was `http://localhost:9630/mcp/tools/call`, now `chamberUrl('obiwan')`
  3. Ollama fallback — was `http://100.79.35.36:11434`, now `http://localhost:11434`
- Claude model in `claudeStream()` updated from `claude-3-5-sonnet-20241022` → `claude-sonnet-4-6`

**Rule going forward**: All chamber URLs must go through `chamberUrl(key)` from `lib/chambers.ts`.
That function reads `FIELD_<KEY>_URL` from env and falls back to `localhost:PORT`. Never hardcode
an IP or port directly in app code. To switch to Tailscale (remote device), change `.env.local` only.

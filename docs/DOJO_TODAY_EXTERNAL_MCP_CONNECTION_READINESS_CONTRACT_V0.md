# DOJO Today — External MCP Connection Readiness Contract v0

**Status:** `SEATED.SPEC` · design before connect
**Surface:** DOJO Today → Settings → MCP servers (ordinary); Developer Space (diagnostics)
**Not:** live new MCP connections · first-screen tool dump · external MCP as FIELD truth authority

**Parents / lessons:**
Claude Code MCP Alignment diagnostic · Free Radical dual-protocol pattern · MCP OAuth / canonical config · Vertex Witness Layer-2 / Layer-3 · Free-Tier Evaluation FIELD verb scoring · Tier 2 capability certification posture (`PROMOTE` only with receipts)

---

## Core lessons (locked)

| Lesson | Meaning |
|--------|---------|
| **Configured ≠ connected** | A row in config/registry is not a live session. |
| **Reachable ≠ answering** | TCP/HTTP/process up is not a successful tool/list response. |
| **Answering ≠ FIELD-compliant** | A tool reply is not sovereignty, truth, or chamber authority. |
| **Tools, not authorities** | External MCPs never outrank runtime evidence, canon, or Arbiter. |
| **Quiet degrade + easy disable** | Failures do not crash Today; one control disables the server. |
| **Writes need confirmation + receipts** | No silent mutation; every write path has policy + receipt. |

**Composer gate (hard):**
No external MCP is exposed to the composer until it has a **read-only smoke test receipt** at status ≥ `Responding` (or documented `Limited` with read-only tools only).

---

## 1. Settings → MCP Servers section

**Ordinary Settings placement** (benchmark parity; not first screen):

```text
Settings
  └─ MCP servers
       ├─ Server list (name · transport · stage · enable toggle)
       ├─ Selected server detail
       │    ├─ Connection stage + last smoke receipt link
       │    ├─ Login / Connect / Disconnect / Disable
       │    ├─ Transport + endpoint (non-secret)
       │    ├─ Write policy summary
       │    └─ Tool inventory (collapsed; names + risk only)
       └─ “Run read-only smoke test” (never fakes success)
```

**Must not appear in MCP Servers ordinary UI:**

- Raw full tool JSON schemas on first open
- HOLD matrices / FIELD architecture lectures
- Build logs / packet dumps
- Auto-promotion language (“canonical authority”)

**Developer / Advanced only:**

- Full schema dump
- Transport traces
- Smoke request/response payloads
- Registry file paths

---

## 2. MCP connection registry model

Machine-oriented seat (future JSON under Application Support or suite config). **Not** live-connected by presence in the file.

```json
{
  "schema": "DOJO.Today.MCPConnectionRegistry.V0",
  "version": 0,
  "servers": [
    {
      "id": "string",
      "display_name": "string",
      "enabled": false,
      "transport": "stdio|http|sse|remote_oauth|unknown",
      "endpoint_or_command": "string|null",
      "auth": {
        "mode": "none|api_key|oauth|unknown",
        "secret_ref": "keychain://…|null",
        "login_required": false
      },
      "stage": "not_connected|needs_login|connected|reachable|responding|limited|failed|disabled",
      "write_policy": "read_only|draft_only|write_with_confirmation|destructive_with_confirmation|forbidden",
      "field_verbs": ["OBSERVE"],
      "composer_exposed": false,
      "last_smoke_receipt_id": "string|null",
      "last_smoke_at": "ISO-8601|null",
      "notes": "string|null",
      "holds": ["HOLD.*"]
    }
  ]
}
```

**Rules:**

- `enabled: false` or `stage: disabled` → no process spawn, no network, no composer tools.
- `composer_exposed: true` only if smoke receipt exists and policy allows.
- External servers never receive `authority: field_chamber` or truth-rank fields.

---

## 3. Connection status stages

Ordered ladder (do not skip upward without evidence):

| Stage | Evidence required |
|-------|-------------------|
| **Not connected** | No session; config may exist |
| **Needs login** | Auth required; secrets missing or expired |
| **Connected** | Transport session established (stdio child / HTTP session / OAuth token present) |
| **Reachable** | Health or ping endpoint / process alive responds at transport layer |
| **Responding** | `tools/list` or equivalent returns a parseable tool inventory |
| **Limited** | Responding but tools restricted, quota, or partial inventory |
| **Failed** | Error after attempt; previous stage may be preserved in receipt |
| **Disabled** | Operator or policy off; no automatic reconnect |

**UI mapping:**

- Ordinary: stage badge + short reason
- Blocking only when user tries composer use without smoke
- Never show “Connected” green for mere config presence

---

## 4. Transport classification

| Transport | Notes |
|-----------|--------|
| **stdio** | Local process; command + args; Free Radical dual-protocol often here |
| **HTTP** | Request/response MCP HTTP |
| **SSE** | Server-sent events stream |
| **remote OAuth MCP** | Remote host + OAuth client; token in Keychain |
| **unknown** | Unclassified — cannot smoke-pass until classified |

Classification is **descriptive**, not a trust upgrade.

---

## 5. Tool inventory model

Per tool (after Responding):

| Field | Values / notes |
|-------|----------------|
| `name` | Tool identifier |
| `summary` | One line; no full schema in ordinary UI |
| `side_effect` | `read` · `write` · `destructive` · `unknown` |
| `confirmation_required` | `true` if write/destructive or policy says so |
| `risk` | `low` · `medium` · `high` · `unknown` |
| `field_verbs` | Subset of §6 that this tool may support |
| `composer_eligible` | Default `false` until smoke + policy |

**Ordinary UI:** name · side_effect · risk · confirmation flag.
**Developer UI:** full input schema if needed.

---

## 6. FIELD verb evaluation

External tools are scored for **capability fit**, not authority:

| Verb | External MCP role |
|------|-------------------|
| **OBSERVE** | Read state, list, fetch, search (preferred first smoke) |
| **MAP** | Structure / transform views without side effects |
| **VALIDATE** | Check shapes/receipts; never invent truth |
| **ROUTE** | Suggest next surface; does not become Arbiter |
| **EXECUTE** | Mutating action — confirmation + write policy |
| **ANCHOR** | Point to evidence paths/URLs; does not own canon |
| **HOLD** | Refuse or stop; preferred on ambiguity |

**Scoring (Free-Tier style, local):**

- Prefer servers with clear OBSERVE tools for first smoke
- EXECUTE without confirmation path → `write_policy` cannot be open write
- No verb grants chamber precedence

---

## 7. Write policy

| Policy | Meaning |
|--------|---------|
| **Read-only** | Only OBSERVE/MAP/VALIDATE-class tools; default for new externals |
| **Draft-only** | May prepare drafts/local proposals; no remote mutate |
| **Write with confirmation** | Mutate only after explicit operator confirm + receipt |
| **Destructive with confirmation** | Delete/overwrite only with stronger confirm + receipt |
| **Forbidden** | No mutate tools exposed; disable writes even if server offers them |

**Default for any newly registered external MCP:** `read_only` until operator raises policy with smoke evidence.

---

## 8. Receipt shape — connection / smoke test

One receipt per test attempt (Application Support or suite logs). **Never invent success.**

```json
{
  "schema": "DOJO.Today.MCPSmokeReceipt.V0",
  "receipt_id": "uuid",
  "server_id": "string",
  "started_at": "ISO-8601",
  "finished_at": "ISO-8601",
  "transport": "stdio|http|sse|remote_oauth|unknown",
  "stages_attempted": ["connected", "reachable", "responding"],
  "stage_result": "not_connected|needs_login|connected|reachable|responding|limited|failed|disabled",
  "ok": false,
  "error": "string|null",
  "http_or_process_code": "string|null",
  "tools_listed_count": 0,
  "tools_sample": [{"name": "string", "side_effect": "read|write|destructive|unknown"}],
  "field_verbs_supported": ["OBSERVE"],
  "write_policy_applied": "read_only",
  "composer_exposure_allowed": false,
  "read_only_smoke": true,
  "faked_success": false,
  "operator_note": "string|null"
}
```

**Hard rules:**

- `ok: true` only if stage ≥ `Responding` with real inventory (or `Limited` with non-empty tools and no transport error)
- `faked_success` must always be `false` in shipped code
- `composer_exposure_allowed: true` only if `read_only_smoke` and policy allows

---

## 9. Developer diagnostics placement

| Placement | Content |
|-----------|---------|
| **Settings → MCP servers** | Stage, last receipt id, Connect/Disable, collapsed tool names |
| **Settings → Developer / Advanced → MCP diagnostics** | Full schemas, traces, raw errors, registry path |
| **Developer Space sheet** | Same diagnostics; not ordinary Today centre/right dock |
| **Proof drawer** | Optional attach of smoke receipt path when operator requests proof |
| **First screen / composer** | No diagnostics · no raw schemas · no MCP status dumps |

---

## 10. Composer exposure rule (hard gate)

```text
composer_exposed :=
  server.enabled
  AND stage ∈ { Responding, Limited }
  AND last_smoke_receipt.ok == true
  AND last_smoke_receipt.read_only_smoke == true
  AND write_policy ≠ forbidden for any exposed tool’s side_effect
  AND no tool with side_effect write|destructive exposed unless policy + confirmation wired
```

Until then:

- Tools do not appear in composer mode/tool picker
- Side chat / Review may show “MCP available in Settings” only if useful — not a dashboard of schemas

---

## Authority boundary

```text
External MCP  ≠  chamber MCP truth
External MCP  ≠  Arbiter
External MCP  ≠  GROUND_TRUTH
Signal from external MCP = Signal until anchors + higher authority
```

Chamber Free Radical MCPs remain FIELD infrastructure under existing canon.
**This contract governs external / third-party MCP attachment to DOJO Today.**

---

## Quiet degrade

| Event | Behavior |
|-------|----------|
| Process crash | Stage → Failed; disable optional; UI toast/status popover only |
| Auth expiry | Stage → Needs login; composer tools hidden |
| Partial tools | Stage → Limited; expose only read-class if smoke passed |
| Smoke fail | Do not set Connected green; keep prior receipt |

---

## Out of scope (this v0)

- Connecting new external services
- Implementing OAuth live flows
- Auto-discovery of network MCPs
- Making external MCP the primary work surface
- FIELD memory integration

---

## One line

**Configured → Connected → Reachable → Responding → (Limited) — only then, with a read-only smoke receipt, may tools touch the composer; external MCPs remain tools, never FIELD authorities.**

---

## Minimal UI patch recommendation (only)

**Single bounded patch (when you ask to implement):**

1. In Settings → **MCP servers** detail pane, replace the generic blurb with:
   - Empty registry list (0 servers)
   - Static stage legend (the 8 stages)
   - Copy: “No external MCP is exposed to the composer until a read-only smoke receipt exists.”
   - Disabled **Add server** / **Run smoke test** buttons (placeholders; no network)
2. In Developer Space, one line: path where smoke receipts **will** live
   (`~/Library/Application Support/org.field.dojo/mcp_smoke_receipts/`)

**Do not in that patch:** register real servers, spawn processes, or wire composer tools.

**Acceptance:** Settings shows readiness contract posture without implying any MCP is connected.

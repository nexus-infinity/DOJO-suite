# DOJO Today — Under-the-Hood / System Inspector Contract v0

**Status:** `SEATED.SPEC` · progressive disclosure layers
**Metaphor:** “Lift the hood”
**Product destination:** **System Inspector**
**Not:** first-screen dump · Settings-as-explanation · Proof-as-workspace · Diagnostics-as-default

**Related:**
`DOJO_TODAY_PANEL_CONTRACT_V0.md` · `DOJO_TODAY_EXTERNAL_MCP_CONNECTION_READINESS_CONTRACT_V0.md` · workspace shell utility dock

**Design anchors:** progressive disclosure · contextual inspector · separation of concerns · Apple/Xcode/VS Code layered workspace patterns

---

## Product law (locked)

```text
Inspection is not operation.
Proof is not workspace.
Diagnostics are not settings.
Settings are not explanations.
Background means background, but inspectable.
```

---

## Layer model

| Layer | Product label | Question | Scope |
|-------|---------------|----------|--------|
| **1. Workspace** | Workspace | What am I doing? | Primary task surface (places · centre work · utility dock · composer · top status) |
| **2. Details** | Details | What is this object? | **Selection-scoped** contextual inspector |
| **3. Proof** | Proof | Can I verify this? | **Object/action-scoped** provenance / audit trail |
| **4. System Inspector** | System Inspector | How is the system behaving? | **App-scoped** summarized logic & state |
| **5. Diagnostics** | Diagnostics | What happened at machine level? | Raw machinery; Developer/Advanced entry only |
| **Settings** | Settings | How do I want it configured? | Persistent preferences only |

### Vocabulary by layer

| Layer | Language |
|-------|----------|
| Workspace | Ready · Local · Needs decision · Saved · Held · Proof available |
| System Inspector | OBSERVE/MAP/VALIDATE/ROUTE/EXECUTE/ANCHOR/HOLD · Layer 2 reachable · Layer 3 responding · write policy |
| Diagnostics | HOLD.* · schemas · traces · receipt JSON · process paths |

FIELD labels appear in Inspector/Diagnostics unless a HOLD **blocks** ordinary action (then plain language + optional Inspect).

---

## Entry points

| Layer | Open from |
|-------|-----------|
| Details | Right utility **Details** · object **Details** · follows selection |
| Proof | Left **Proof** · Details → Proof · Status → Open Proof |
| System Inspector | Status popover → **Inspect System** · Settings → Developer/Advanced → System Inspector · (later) command palette |
| Diagnostics | System Inspector → **Diagnostics** (explicit) |
| Settings | Top gear only for configuration |

---

## What each layer must / must not show

### Workspace
- **Must:** clean work; selected object body; composer
- **Must not:** raw MCP schemas, FIELD architecture essays, build logs, HOLD matrices

### Details (contextual inspector)
- **Must:** title, type, created, provider/model, source prompt, inputs/attachments summary, save/export state, short provenance
- **Must not:** whole-system MCP list, pipeline dump, raw JSON by default
- **Actions:** Proof · Copy metadata · Open in System Inspector (object context)

### Proof
- **Must:** receipt path, hash if any, anchors, run id, timestamp, tool/model, witness status, object-specific HOLDs
- **Must not:** replace centre workspace; global receipt dashboard as default

### System Inspector
Sections (summarized, human-readable, mostly read-only):

```text
Pipeline · MCP Connections · Models & Providers · Tools
Memory · Attributes · Receipts · Jobs · Panels · Holds · Diagnostics
```

- **Must not:** perform normal work operations; show raw JSON by default

### Diagnostics (inside Inspector)
- Raw tool schemas · MCP traces · request/response · build/DerivedData paths · PIDs · G6/packet · Boundary Capacity internals
- Requires explicit Developer/Advanced path

### Settings
- Configure only (providers, keys, MCP policy prefs, appearance…)
- Not architecture lectures; not live system dump

---

## Right utility dock (workspace-adjacent)

```text
Details | Review | Files | Browser | Terminal | Side Chat
```

- **Details** = selection inspector (industry “Inspector”)
- **Review** = inspect changes / evidence summary for work (not system-wide)
- Only one mode visible; dock collapsible

---

## Status popover (top bar)

Compact chip → popover:

```text
App: Local mode · Receipts · Memory state · Model API state
Connections: summary lines (not full MCP console)
Holds: user-facing, plain language
[Open System Inspector]  [Open Proof]
```

`Local`, `Receipts on`, boundary test, multi-pill chrome live **here**, not permanent top-bar pills.

---

## Progressive disclosure chain

```text
Workspace work
  → Details (this object)
    → Proof (evidence for this object/action)
      → System Inspector (how system decided)
        → Diagnostics (raw machine)
```

Each step is deliberate. No single giant System sheet mixing all five.

---

## Relation to MCP readiness

External MCP Connection Readiness Contract governs **when** tools connect.
System Inspector **MCP Connections** section is the **inspection home** for stages/receipts summaries — not the composer, not Settings explanation essay.

---

## Minimal first patch (this seating)

1. Top status popover (human-readable + Inspect System / Proof)
2. System Inspector shell (section tabs; summary placeholders)
3. Details as right-utility mode (selection-aware)
4. Proof drawer remains separate
5. Diagnostics tab placeholder inside System Inspector

No live MCP diagnostics required in first patch — correct **homes** only.

---

## Screenshot witness list

1. Ordinary workspace clean
2. Status popover open
3. System Inspector — Pipeline
4. System Inspector — MCP Connections
5. Details (utility) for a generated object
6. Proof drawer open
7. Diagnostics tab open, clearly separate

---

## One line

**Lift the hood into System Inspector; verify in Proof; configure in Settings; work in the Workspace — never collapse those jobs into one surface.**

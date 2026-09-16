# DOJO Today — Boundary Function + Settings Parity Pass

**Timestamp:** 2026-08-07T13:56:04+1000
**Build:** `xcodebuild -scheme DOJOApp` → **BUILD SUCCEEDED**
**Decisions this pass:**

| Pin | Status |
|-----|--------|
| `PASS.FirstScreenLayerSeparation` | retained (prior) |
| `PASS.PanelBoundaryFunctionality.UI` | **candidate** — rails fold/restore, object shells, settings parity, proof secondary |
| `HOLD.PanelBoundaryFunctionality.HumanWitness` | interactive screenshot / click-through still needed |
| `PASS.SettingsBenchmarkParity.Structure` | left categories + right detail + search + placeholders |
| `HOLD.SettingsBenchmarkParity.LiveConnectors` | no real Connect / Test network |
| `PASS.GeneratedObjectSpaceBehavior.Shells` | answer/doc/image/table/media/codeDiff containers |
| `HOLD.GeneratedObjectSpaceBehavior.Persistence` | in-session only; no disk objects yet |
| Memory / local models / FIELD primary / backend claims | **not** integrated (explicit) |

---

## Files changed

1. `Sources/DOJOApp/Views/DOJOTodaySurfaceView.swift` — full boundary pass
2. This receipt

---

## Boundary functions implemented

| Function | Behavior |
|----------|----------|
| Left rail collapse | Icon-only rail; place selection preserved; center expands |
| Left restore | Sidebar control on collapsed rail + **Places** chip in top bar |
| Right rail collapse | Icon strip + restore; object selection preserved |
| Right restore | Sidebar control + **Context** chip in top bar |
| Session persistence | `@State` for both rails for session lifetime |
| Canvas expand | `canvasMaxWidth` grows when rails collapse |
| Proof secondary | `Proof…` / details only |
| Boundary test mode | Top **Boundary test** toggle + action chips |

---

## Settings sections implemented

Left category list + right detail pane + search field:

Account / profile · Models & providers · API keys · Agents · Skills · Connectors · MCP servers · Voice & capture · Files & media · Memory (“Not enabled yet”) · Receipts & history · Privacy & local/cloud · Appearance · Keyboard shortcuts · Notifications · Storage · Developer / Advanced

Benchmark patterns: toggles, pickers, masked API key, Connect/Disconnect placeholder, disabled Test connection, no FIELD architecture dump, no HOLD matrix as main content.

---

## Generated object shells

| Kind | Shell |
|------|--------|
| Answer | text body + actions |
| Document | markdown-style preview |
| Image | placeholder frame |
| Table | monospaced grid text |
| Media / audio | play + waveform stub |
| Code / diff | Dev-gated; visible in Boundary test seed |

Each: title · type badge · preview/body · Continue · Save · Export · Details (metadata; proof optional).

Empty state only when no objects. Continue on composer creates a local Answer shell (no network).

---

## Screenshot / test witness instructions

1. Launch **DOJO Today** (Debug `DOJOApp`).
2. Toggle **Boundary test**.
3. Click **Collapse left** → canvas widens; place icons remain; selected place preserved.
4. Click **Restore left** (chip or sidebar).
5. Click **Collapse right** / **Restore right** same way.
6. Click **Seed objects** → six shells (code/diff included in test mode).
7. Select an object → right **Object** panel updates; **Details** opens metadata sheet; proof optional.
8. Gear → **Settings** → switch categories; search “API”; open **Memory** (“Not enabled yet”); **Developer / Advanced** → Developer Space.
9. **Proof…** opens separately; Boundary Capacity only under disclosure.
10. Type in composer → **Continue** → new Answer object (not a log row).
11. Confirm: no network, no real keys required, no memory/models, no authority claim UI.

---

## Remaining HOLDs

- Human interactive witness / screenshots for boundary fold
- Real provider Connect / API key storage (Keychain)
- Disk persistence of generated objects
- Drag-drop file attach wiring
- Voice capture wiring
- Memory integration (explicitly out of scope)
- Local models (explicitly out of scope)
- Cross-session rail collapse preference (optional UserDefaults later)

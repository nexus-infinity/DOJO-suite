# DOJO Today Panel Contract v0 — First Screen Patch

**Timestamp:** 2026-08-07T13:36:03+1000
**Classification:** `CANDIDATE.PASS.BackgroundMeansBackground` (code layout) · screenshot proof still operator-side
**Runtime claim:** none · no authority promotion · no live sync

---

## Objective

Seat Panel Contract v0 + MacWarp salvage map; patch `DOJOTodaySurfaceView` into contracted first screen.

---

## Files created

| Path | Role |
|------|------|
| `docs/DOJO_TODAY_PANEL_CONTRACT_V0.md` | Full 8-panel contract seat |
| `docs/MACWARP_SALVAGE_MAPPING_V0.md` | KEEP / ADAPT / DO NOT salvage map |

## Files changed

| Path | Role |
|------|------|
| `Sources/DOJOApp/Views/DOJOTodaySurfaceView.swift` | First-screen layout rewrite |
| `DOJO-suite.xcodeproj` | Regenerated via xcodegen |

---

## First screen structure (implemented)

```
┌ status: DOJO · place · Local · Receipts on · ⚙ ────────────┐
│ left places │ center canvas          │ right context       │
│ Today       │ greeting               │ Continue card       │
│ Threads     │ large capture/composer │ Attention hint      │
│ Captures    │ generated objects empty│ No object selected  │
│ Media       │                        │                     │
│ Documents   │                        │                     │
│ Projects    │                        │                     │
│ New capture │                        │                     │
│ Proof…      │                        │                     │
├────────────────────────────────────────────────────────────┤
│ bottom composer: mic · attach · input · mode · Continue    │
└────────────────────────────────────────────────────────────┘
```

### Visible (ordinary use)

- Left rail places (core first-screen set)
- Center: greeting + dominant capture area + generated-object empty state
- Bottom composer: voice / attach / text / mode / Continue
- Right: one continue card + one quiet attention badge + no-object default
- Status pills only: **Local**, **Receipts on**

### Behind disclosure (not first-screen content)

- Proof drawer sheet (`Proof…` / Show details…)
  - Boundary Capacity glance under disclosure
  - Receipt paths under disclosure
- Settings sheet (gear) — preferences only
- Developer Space only via Settings → Developer / Advanced

### Removed from first screen vs prior shell

- Action grid as primary dashboard
- Media object tile strip as main chrome
- “Held items available” status pill
- Quiet status panel with Boundary Capacity path on rail
- Full Boundary Capacity card on first screen
- HOLD matrix
- Receipt list as primary panel
- System sheet as primary depth for ordinary work (split into Proof / Settings / Developer)

---

## MacWarp salvage

- KEEP / ADAPT / DO NOT seated in `docs/MACWARP_SALVAGE_MAPPING_V0.md`
- Terminal, registry, shell **not** on Today first screen
- Provider/Keychain concepts reserved for Settings

---

## Build

```text
xcodegen generate → PASS
xcodebuild -scheme DOJOApp -destination 'platform=macOS' build → exit 0
```

---

## Screenshot must prove (operator checklist)

| Requirement | Code layout |
|-------------|-------------|
| Ordinary use primary | Yes |
| Composer/capture dominant | Yes |
| Generated-object/canvas clear | Yes (empty state copy) |
| FIELD internals not first-screen | Yes (atmosphere only) |
| Receipts/proof reachable not dominant | Yes (Proof drawer) |
| No full Boundary Capacity card | Yes (disclosed in drawer) |
| No HOLD matrix | Yes |
| No packet/debug/G6/ParticleBoard | Yes (Developer Space only) |
| No runtime/sync/authority promotion | Yes |

**Human screenshot still required** for visual `PASS.BackgroundMeansBackground` seal.

---

## Next bounded action

1. Launch DOJOApp → capture first-screen screenshot against checklist above.
2. If visual PASS, promote classification to `PASS.BackgroundMeansBackground` with screenshot path.
3. Do not add Archive/Search/Images/Tables to left rail until needed (contract allows; first patch uses core six).

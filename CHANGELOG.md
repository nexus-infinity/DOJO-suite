# DOJO-suite Changelog

All significant changes chronicled here. Newest first.

---

## [Unreleased] — 2026-03-01

### Added — FIELD Design System (5 sacred surfaces)

**`Sources/DOJOUI/DesignSystem/`** — new module, all UI surfaces

| File | Surface | Chamber | Notes |
|------|---------|---------|-------|
| `FieldDesignSystem.swift` | Shared tokens | ◎ Kings | Chamber enum, FieldPalette (tech), FieldType, ChamberBadge, BEARRing, Color hex ext. Bridges to OOOEntity. |
| `FieldSpellCircle.swift` | Shared visuals | ◎ Kings | Doctor Strange / Steve Ditko sacred geometry: SpellCircle (spoke counts per frequency), BEARMandala (sling-ring), ChamberActivationFlash, ChamberInnerSigil |
| `FieldSystemDashboard.swift` | FIELD DOJO (Mac Studio temple) | ◎ Kings | Pyramid layout, all chambers at unit-coord positions, BEARMandala at centre, footer port/stage row |
| `OBIWANWatchFace.swift` | Apple Watch — OBI-WAN ambient | ● 963 Hz | OAW phase arc (Tesla 3-6-9), SpellCircle 9-spoke, coherence trim ring; solo/buffer/live states |
| `ARKADASHomeView.swift` | iPhone home — ARKADAŞ bridge | ◉ 717 Hz | Orbital chamber navigation (6 chambers orbit ◉); OB1/Dojo/Soma link pills; AppCard grid (Niama, Response Advantage, Berjak FRE, Kit Car) |

**`Sources/DOJOShared/Services/OBIWANState.swift`** — offline-first observer bridge; `alignment` property (0–1 coherence); buffers locally, flushes to :9630

### Architecture decisions recorded

- **Chamber models do not deploy to Apple devices.** DOJO Suite apps are MCP clients that call Mac Studio chamber endpoints over HTTP/WebSocket.
- **MLX + GGUF** = DOJO 20B quantization pipeline only (on Mac Studio). Not on-device inference.
- **Two-palette system** preserved:
  - Chakra palette → `OOOEntity.geometric.color` (semantic identity, docs)
  - Tech palette "Days of Future Past" → `Chamber.color` (app UI rendering)
- **ARKADAŞ canonical split** documented:
  - ◉ ARKADAŞ (SPIN) = 717 Hz — model-bearing vertex, `Chamber.arkadas`
  - ⊗ Kings Chamber = 852 Hz — infrastructure, `OOOEntity.arkadas` (TODO: rename to `kingsChamber` in future cleanup)

### Remaining surfaces (to complete)
- [ ] Mac DOJO Suite cockpit — all chambers + SPIN status + operator view
- [ ] Kit Car HUD — T0-T5 compute tier, HAL sensor feed indicator

---

## [Prior] — DOJO-suite initial modular workspace

See git log for earlier history.

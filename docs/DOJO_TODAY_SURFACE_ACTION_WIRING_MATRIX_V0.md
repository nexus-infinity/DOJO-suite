# DOJO Today — Surface Action Wiring Matrix V0

**Status:** `SEATED.WIRING_AUDIT` · living matrix
**Decision:** `PROMOTE.M1AttentionConstraintsIntegrated` · `NEXT.SurfaceActionWiringAudit` · `HOLD.FullInteractionPathCoverage`
**Principle:** `visible control → intended action → implementation target → success state → error/hold path`
**Rule:** No silently decorative control. Status labels only: `WIRED` · `PARTIAL` · `PLACEHOLDER` · `DISABLED` · `BROKEN` · `HOLD`

**Not this pass:** memory · local models · MCP execution · FIELD governance primary UI · new design doctrine

---

## Status legend

| Label | Meaning |
|-------|---------|
| **WIRED** | Path works end-to-end for the declared action |
| **PARTIAL** | Some of the path works; gaps are named |
| **PLACEHOLDER** | Visible, honest empty/later state; not live |
| **DISABLED** | Not clickable / looks inactive |
| **BROKEN** | Looks live but fails silently or misroutes — must fix |
| **HOLD** | Intentionally deferred with named reason |

---

## 1. Top bar

| Control | User action | Expected | Implementation | Success | Error | Persist | Status |
|---------|-------------|----------|----------------|---------|-------|---------|--------|
| Breadcrumb `DOJO · place · object` | Read-only | Orient | `currentWorkspaceLabel` | Label updates | — | — | **WIRED** |
| Status chip | Click | Status popover | `$showingStatusPopover` | Popover | — | — | **WIRED** |
| Status `No key` CTA | Open API keys | Settings → API keys | `openSettings(section: .apiKeys)` | Sheet | — | — | **WIRED** |
| Status → System Inspector | Click | Inspector sheet | `showingSystemInspector` | Sheet | — | — | **WIRED** |
| Status → Proof | Click | Proof drawer | `showingProofDrawer` | Sheet | — | — | **WIRED** |
| Receipts toggle | Toggle | Flag only (no ledger UI) | `$receiptsPolicyOn` | Toggle flips | — | In-session only | **PARTIAL** |
| Boundary test toggle | Toggle | Dev layout helpers | `$boundaryTestMode` | Mini actions | — | In-session | **WIRED** (dev) |
| Layout / Tools toggle | Click | Expand/collapse right dock | `openRightPanel` / `collapseRightPanelToHorizon` | Dock state | — | — | **WIRED** |
| Settings gear | Click | Settings sheet | `showingSettings` | Sheet | — | — | **WIRED** |
| Places chip (when collapsed) | Click | Expand left | `leftRailCollapsed = false` | Left expands | — | — | **WIRED** |
| Loading ProgressView | — | Only while request | `isRequesting` | Visible during Send | — | — | **WIRED** |

---

## 2. Left panel

| Control | User action | Expected | Implementation | Success | Error | Persist | Status |
|---------|-------------|----------|----------------|---------|-------|---------|--------|
| Today / Threads / Captures / Media / Documents / Projects | Select | Centre place changes; selection kept on collapse | `selectedPlace` + `canvasSubtitle` + filtered recents | Empty copy + filter | — | Selection in-session | **PARTIAL** (no dedicated data stores per place) |
| Collapse / expand | Click | Preserve `selectedPlace` | `leftRailCollapsed` | Place still selected | — | — | **WIRED** |
| New capture | Click | Capture mode + focus composer | `selectedMode = .capture`, clear object, empty composer | Capture mode | — | — | **WIRED** |
| Proof | Click | Proof drawer | `showingProofDrawer` | Sheet | Empty if no object | — | **WIRED** |

---

## 3. Centre panel

| Control | User action | Expected | Implementation | Success | Error | Persist | Status |
|---------|-------------|----------|----------------|---------|-------|---------|--------|
| Empty state | View | Calm orient copy | `emptyWorkView` | Greeting + place subtitle | — | — | **WIRED** |
| Render projection (Investigations) | View | Two typed `dojo` tuples, read-only | `LocalDojoTodayRenderBridge` + `dojoRenderProjectionBand` | pyramid/octagon cards | Fail-closed drop | Witnessed snapshot | **WIRED** (snapshot only; live Notion MCP still HOLD) |
| Recent work row | Click | Open object + Details | `selectedObjectID` + `openRightPanel(.objectSelected)` | Object centre | — | Session/disk | **WIRED** |
| Object body | View | Text of answer | `selectedWorkView` | Scrollable body | — | — | **WIRED** |
| Close | Click | Clear object + horizon dock | `selectedObjectID = nil` + collapse | Empty centre | — | — | **WIRED** |
| Non-answer kinds | Open | Honest shell | Same centre view | Body shown | No special editors | — | **PARTIAL** (shell only) |

---

## 4. Right utility dock

| Control | User action | Expected | Implementation | Success | Error | Persist | Status |
|---------|-------------|----------|----------------|---------|-------|---------|--------|
| Expand / collapse | Click | Boundary open / horizon | `openRightPanel` / collapse | Width change | — | — | **WIRED** |
| Details | Select | Object metadata + recovery | `detailsUtility` | Rows filled | Empty copy if none | — | **WIRED** |
| Review | Select | Actions on object | `reviewUtility` | Continue/Save/Export | Empty + open list | — | **WIRED** |
| Files | Select | Paths or placeholder | `filesUtility` | Paths selectable | Placeholder label | Paths only | **PARTIAL** (paths, no browser) |
| Browser / Web | — | Not shown as ordinary utility | Removed from `RightUtilityMode` | No misleading tab | Developer depth only | — | **HOLD** |
| Terminal | — | Not shown as ordinary utility | Removed from `RightUtilityMode` | No misleading tab | Developer depth only | — | **HOLD** |
| Side chat | — | Not shown as ordinary utility | Removed from `RightUtilityMode` | No misleading tab | Hosted composer remains primary | — | **HOLD** |

---

## 5. Bottom composer

| Control | User action | Expected | Implementation | Success | Error | Persist | Status |
|---------|-------------|----------|----------------|---------|-------|---------|--------|
| Mic | View | Visible unavailable input affordance | Non-interactive image with HOLD help | Affordance remains visible and honest | No click path | — | **HOLD** / **PLACEHOLDER** |
| Attach / drop | Choose or drop local files | Native file chooser or drag-and-drop; stage metadata for a local Capture; model analysis remains held | `NSOpenPanel` / `onDrop` → session-scoped `attachedFiles` → Capture-only `GeneratedObjectShell` body metadata | Selected filename/type/size is visible and the existing local receipt loop can complete | Cancel leaves state unchanged; DOJO/hosted send with staged files returns visible `HOLD` | Local object/receipt only after Capture | **WIRED** (chooser + drop code; chooser runtime-witnessed, multimodal analysis held) |
| Text field | Type | Edit prompt | `$composerText` | Text updates | Disabled while request | — | **WIRED** |
| Mode DOJO | Select | Send through the DOJO spinning-top mirror portal | `selectedMode == .dojoPortal` → `submitDojoPortalIntent` → `SpinningTopClient` | Real portal response → Answer object in Threads | Unreachable endpoint → visible error / no fallback | Session | **WIRED** (round-trip witnessed; inference may remain unavailable) |
| Mode Ask | Select | Hosted send path | `selectedMode == .ask` | Send → API | No key → Settings | — | **WIRED** |
| Mode Capture | Select | Local capture object | `createLocalCapture()` | Object without API | Empty text | Session | **WIRED** |
| Mode Review | Select | Open Review dock | `openRightPanel(.explicitReviewOrDetails, .review)` | Dock Review; text remains local to Review mode | — | — | **WIRED** (does not enter hosted send path) |
| Provider picker | Change | Updates model list + prefs | `onChange` + `M1Preferences` | Model list | — | UserDefaults | **WIRED** |
| Model picker | Change | Current model | `$selectedModelID` + prefs | Tag | — | UserDefaults | **WIRED** |
| Send | Click | DOJO portal, hosted advisory, capture, or review action | `submitDojoPortalIntent` / `submitHostedIntent` / capture / settings | Answer object or local capture | Visible banner; no silent fallback | Session / Keychain keys | **WIRED** |
| Loading | — | Indicator only in flight | `isRequesting` | ProgressView | — | — | **WIRED** |
| Continue | Via Review | Context + composer | `continueFrom` | Composer primed | — | Recovery fields | **WIRED** |

---

## 6. Object actions

| Control | User action | Expected | Implementation | Success | Error | Persist | Status |
|---------|-------------|----------|----------------|---------|-------|---------|--------|
| Save | Click | Write JSON | `GeneratedObjectStore.save` | status “Saved” | Banner | App Support JSON | **WIRED** |
| Export | Click | MD clipboard + file | `GeneratedObjectStore.export` | Path in status | Banner | Docs/DOJO-Exports | **WIRED** |
| Details sheet | Click | Metadata sheet | `objectDetailsTarget` | Sheet + recovery | — | — | **WIRED** |
| Open Recent | Click | Select + right panel | See centre | Object open | — | — | **WIRED** |
| Close | Click | Horizon | See centre | Empty | — | — | **WIRED** |

**Persistence path:** `~/Library/Application Support/org.field.dojo/generated_objects.json`

---

## 7. Settings

| Section | Expected | Status |
|---------|----------|--------|
| Models & providers | Affects composer defaults | **WIRED** |
| API keys | Save/test/remove Keychain + live test | **WIRED** |
| Voice & capture | Mac devices + test | **PARTIAL** (Mac path; STT/packet later) |
| Memory | “Not enabled yet” | **PLACEHOLDER** / **HOLD** |
| Developer / Advanced | Inspector + Developer Space | **WIRED** |
| Account, Agents, Skills, Connectors, MCP, Files, Receipts, Privacy, Appearance, Shortcuts, Notifications, Storage | Honest later copy + **PLACEHOLDER** badge | **PLACEHOLDER** |

---

## 8. Proof / Inspector / Developer

| Control | Expected | Status |
|---------|----------|--------|
| Proof drawer | Object-scoped provenance sheet | **PARTIAL** (honest unverified rows; no hash) |
| System Inspector | App-scoped under-hood | **WIRED** (read-only) |
| Developer Space | Paths + wiring checklist | **WIRED** (checklist) |
| MCP diagnostics | Empty read-only registry, stage ladder, smoke receipt path | **WIRED** (no live MCP) |
| Boundary Capacity | Inspector/elsewhere | **HOLD** / secondary |

## 9. Surface capacity seam

| Capacity | Experience behaviour | Processing / authority effect | Status |
|----------|----------------------|------------------------------|--------|
| Expansive | Open centre canvas with leading-edge hero, contextual dock, labelled actions and provider/model controls | None; view-only capacity classification | **WITNESSED** (`1,920 × 1,048` runtime specimen; comparative benchmark remains HOLD) |
| Working | Full centre with narrower labelled controls where they fit | None; view-only capacity classification | **WITNESSED** (developer measurement overlay) |
| Compact | Centre remains dominant; utility dock at horizon until explicit Tools; hosted provider/model behind one menu; actions may become icons | None; no routing, persistence, or authority change | **WITNESSED** (runtime surface) |
| Accessibility enlargement | Required independent specimen for enlarged content / reduced width; centre content remains scrollable | None intended | **WITNESSED** (compact scroll specimen; full cross-capacity comparison **HOLD**) |

The capacity seam is an experience-layer mirror of available presentation space. It does not create a fourth processing channel and does not decide intention, evaluation, authority, or truth.

---

## Acceptance (this pass)

| Criterion | Result |
|-----------|--------|
| No silently dead visible button | **Target met** after A/B/C patches (mic/attach disabled; placeholders labeled) |
| Placeholders visibly placeholders | **Yes** (badge + copy) |
| Disabled look disabled | **Yes** (mic/attach) |
| Primary loop or missing-key route | **Yes** |
| Save/export | **Yes** |
| Settings affect app where relevant | **Models + API keys yes**; others placeholder |
| Proof/developer secondary | **Yes** |

**Remaining HOLD:** full interaction path coverage (live MCP connections, memory, true per-place stores, terminal execution, attach/mic live, hash proof).

---

## Manual click-through

See bottom of this file after implementation, or receipt companion.

1. Cold open → right dock horizon, centre empty, status Ready or No key
2. If No key → Open API keys → paste → Save & Test
3. Provider/model pickers → Send prompt → Answer centre + Details
4. Save → disk JSON; Export → markdown path
5. Close → horizon; Recent → reopen + Details
6. Proof → drawer; Settings sections → PLACEHOLDER vs wired
7. Right tabs → Details/Review/Files live; Web/Terminal/Side chat absent from ordinary dock
8. Left places → subtitle + collapse preserves selection
9. New capture → Capture mode + local capture on Send
10. Mic → visible HOLD affordance, help text; Attach → choose a local file, then Capture to issue a metadata-only local receipt

---

## One line

**Every button either works, explains itself, or is disabled.**

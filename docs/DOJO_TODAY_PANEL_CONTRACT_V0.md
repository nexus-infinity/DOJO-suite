# DOJO Today Panel Contract v0

**Status:** `SEATED.SPEC` · first-screen UI authority for ordinary use
**Surface:** `DOJOTodaySurfaceView`
**Classification target:** `PASS.BackgroundMeansBackground` (ordinary use primary; internals disclosed)
**Not:** MacWarp rebuild · terminal shell as Today · runtime authority promotion

**Current evaluation extension:** `docs/DOJO_TODAY_FIELD_MATRIX_SURFACE_TEST_V0.md` — Matrix perspective; does not replace this panel contract.
**Identity / form / function benchmarks:** `docs/DOJO_TODAY_IDENTITY_FORM_FUNCTION_BENCHMARK_V0.md`
**Perplexity → spinning top gap analysis:** `docs/PERPLEXITY_SPINNING_TOP_GAP_ANALYSIS_V0.md`

---

## 1. Left Rail — Places / Continuity

**Purpose:** Stable navigation between human work areas.
**Benchmark:** ChatGPT thread/project rail, Claude projects, Codex project rail.

| Belongs | Must not |
|---------|----------|
| Today · Threads · Captures · Media · Documents · Images · Tables · Projects · Archive · Search | HOLD matrices · receipt chains · boundary-capacity internals · packet state · build logs · debug routes · raw FIELD lanes |

**Allowed:** switch place · search · resume thread · open project · create new capture/thread
**Default empty:** Today selected · recent items absent or “No recent thread yet”
**Escalation:** one quiet badge only if blocked (e.g. Needs decision)

---

## 2. Bottom Composer — Intention / Input

**Purpose:** The operator starts here.
**Benchmark:** ChatGPT/Claude composer, Codex “What should we build?”

| Belongs | Must not |
|---------|----------|
| text · voice · attach/drop · mode/tool picker · send/continue · quiet pills: Local, Receipts on | diagnostics · receipts · authority explanations · HOLD lists · route/debug language |

**Allowed:** speak · type · drop · choose mode · submit intent
**Default empty:** “Ask, capture, or drop something…”
**Escalation:** consent sheet / proof drawer **after** intent if proof/permission required

---

## 3. Center Canvas — Active Thread or Selected Object

**Purpose:** Main work surface.
**Benchmark:** Claude artifact panel, ChatGPT canvas, Codex preview space.

| Belongs | Must not |
|---------|----------|
| active conversation · selected object · document/image/media · table · review item · current answer | settings · full receipts · full diagnostics · packet machinery · raw FIELD architecture |

**Allowed:** read · edit · review · approve · continue · export/save · branch
**Default empty:** one calm prompt/capture surface, not a dashboard
**Escalation:** compact object-level warning + link to details if held

---

## 4. Generated Object Space — Output Objects

**Purpose:** Model/app outputs as first-class objects.
**Benchmark:** Claude artifacts, ChatGPT files/images, Codex diffs.

| Belongs | Must not |
|---------|----------|
| generated image/document/table/code · media · transcript · metadata summary · attached proof link | global receipts · system-wide HOLDs · unrelated diagnostics · settings panels |

**Allowed:** inspect · rename · save/export · revise · compare · attach · open object proof drawer
**Default empty:** “Generated objects will appear here.”
**Escalation:** code/build → Developer Space; ordinary media/docs stay on canvas

---

## 5. Right Rail — Momentary Context / Selected-Object Details

**Purpose:** Helpful context for current object or thread.
**Benchmark:** Claude/ChatGPT side details, Codex side tools.

| Belongs | Must not |
|---------|----------|
| object summary · recent related thread · next suggested action · small provenance · one attention hint · object-level status | all receipts · all HOLDs · all settings · build logs · registry internals |

**Allowed:** open details · show proof · mark reviewed · continue related thread · open relevant settings
**Default empty:** “No object selected.”
**Escalation:** if blocked, plain-language why + proof/details offer

---

## 6. Settings — Stable Configuration

**Purpose:** Persistent preferences and capability setup.

**Belongs:** account · local vs cloud · models/providers · Keychain/API keys · tools/connectors · voice/capture · media/files · receipts policy · privacy/sovereignty · notifications · appearance · storage · developer/advanced toggle

**Must not:** current object · active thread · live debug as default · proof trails as primary workspace

**Escalation:** Advanced/internal only via explicit Developer/Advanced entry

---

## 7. Receipts / Proof Drawer — Audit On Request

**Purpose:** Evidence when asked or needed.

**Belongs:** receipt paths · timestamps · hashes/anchors · source links · object proof trail · build/run receipt when relevant · export proof

**Must not:** ordinary first-screen content · primary generated-object workspace · full debug UI unless requested

**Default empty:** “No proof requested.”
**Opens automatically only when:** blocked · proof requested · failure · decision needs evidence

---

## 8. Diagnostics / Developer Space — Internal Machinery

**Purpose:** Debug, build/runtime verification, developer-only trace.

**Belongs:** build logs · launch traces · bundle paths · stale process · renderer identity · G6/ParticleBoard proof rigs · packet internals · route diagnostics · registry traces · shell/API tools

**Must not:** ordinary Today first screen · capture composer · generated media/docs by default

**Default empty:** hidden unless Developer mode opened
**Escalation:** failure/stale launch/proof mismatch → focused trace, not full dump

---

## First-screen patch (v0)

Left rail + center canvas + bottom composer + slim right context rail.

Visible:

- left: Today, Threads, Captures, Media, Documents, Projects
- center: greeting + large composer/capture
- composer: text/voice/drop + Local / Receipts on pills
- right: one recent/continue card + one quiet attention hint

Behind disclosure: Boundary Capacity · receipts · HOLDs · proof trail · diagnostics

### Independent panel zones (shell refinement)

The Today shell keeps three foldable surfaces independent:

- **Places** is the left navigation zone and owns continuity between work areas.
- **Main zone** owns the toolbar, geometry/context strip, centre canvas, and
  composer. The toolbar does not extend across Places.
- **Tools** is the right momentary context zone and opens only when selected or
  explicitly requested.
- **Composer** may fold away independently so the operator can enlarge the work
  canvas without losing the ability to reopen Ask, Capture, or Review.

The toolbar provides a compact **Connections** entry point. It opens the existing
human-readable status summary; it does not turn the workspace into a diagnostics
console. The summary must distinguish local work, hosted model readiness, memory
availability, MCP exposure, receipts, and current holds.

### Deterministic Test Bench (Developer / Advanced)

The Test Bench is the proving surface for the application front end and the
deterministic infrastructure beneath it. It is not part of the ordinary Today
entrance.

The test loop is explicit:

`controlled request → hosted proposal → deterministic route → authority gate → receipt / HOLD`

- The hosted provider uses the existing Keychain-backed HTTPS client and only
  runs after an explicit user action.
- The returned model text is shown as `presentation / advisory`; it is never
  treated as authority because it is visible, structured, or confident.
- The deterministic route reports the canonical DOJO fallback or a
  receipt-admitted specialised route. Topology observation alone cannot admit
  a route.
- The authority gate is fail-closed. Without an exact correlated receipt, the
  result must remain `HOLD` and the UI must say why.
- Correlation ID, stage state, and receipt state remain visible so transitions
  can be tested and re-witnessed. A successful hosted call is not a successful
  deterministic decision.

The first implementation intentionally proves the negative path: a real
proposal can be received and then withheld when no authority proof is present.
Receipt-backed promotion remains a separate, future witnessed seam.

---

## Screenshot must prove — `PASS.BackgroundMeansBackground`

- ordinary use is primary
- composer/capture dominant
- generated-object/canvas space clear
- FIELD internals not first-screen
- receipts/proof reachable, not dominant
- no full Boundary Capacity card
- no HOLD matrix
- no packet/debug/G6/ParticleBoard machinery
- no runtime/sync/authority promotion claim

---

## Implementation home

- View: `Sources/DOJOApp/Views/DOJOTodaySurfaceView.swift`
- MacWarp salvage: `docs/MACWARP_SALVAGE_MAPPING_V0.md`

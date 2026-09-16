# DOJO Today — native surface benchmark reconciliation

Date: 2026-08-30
Object: `DOJO.Today.FlatMacOSSurface`
Scope: Mac native experience and its existing local seams
Decision: `PROMOTE` the local attachment-intake seam; `HOLD` overall production benchmark

## Finding

The prior research establishes a practical product bar before any DOJO-specific differentiation: a user must be able to begin with one clear intention, use the native input surface, see truthful progress, receive a first-class object, review or continue it, and return to prior work. Multimodal means that text, file/image, and voice paths are separately usable and separately honest; it does not mean that every path must share one processing implementation.

The useful lesson from the Perplexity evidence is native integration and low-friction continuity: desktop connectors, permissions, account/device settings, and a research/voice-oriented entry surface are visible product capabilities. The evidence is surface-class evidence only; it does not prove every connector, latency claim, or private-data behaviour.

## Current DOJO Today state

| Capability | Current evidence | Classification |
|---|---|---|
| Mac window, Places, centre canvas, right context, composer | Rebuilt SwiftUI surface and runtime accessibility witness | Runtime-witnessed |
| Place differentiation | Today, Threads, Captures, Media, Documents, Investigations have distinct role/state/guidance | Runtime-witnessed |
| Text → local Capture → object → receipt → review/continue | Existing `GeneratedObjectStore` loop and focused tests | Runtime-witnessed |
| Text → DOJO portal | Existing route with visible inference/error HOLD; one historical success and later fail-closed witnesses | Partial / HOLD for repeatability |
| Text → hosted external model | Existing Keychain-backed route, subject to provider key and live route proof | Partial / HOLD |
| External provider readiness in current Settings | OpenAI is visible as No key; Anthropic, Google, and xAI remain unopened in the progressive key surface | Runtime-witnessed configuration state; live smoke test HOLD |
| File chooser → local metadata Capture | Native `NSOpenPanel`, filename/type/size metadata, existing local receipt loop | Runtime-witnessed in this sitting |
| File drag-and-drop → local metadata Capture | Existing attachment seam now accepts native file drops; no bytes enter a model route | Implemented; runtime witness pending |
| File/image analysis | No multimodal processing adapter is wired | Declared but unimplemented / HOLD |
| Voice input/output | Visible honest HOLD affordance; no completed voice round trip in Today | Declared but unimplemented / HOLD |
| Streaming response | Not established by the current Today route | Unknown / HOLD |
| Complete intention/sequence/evaluation/evidence packet | Typed `TodayProcessingPacket` exists; runtime producer/consumer is not proven | Contract present; runtime HOLD |
| Arkadaş continuity/disagreement | No Today runtime witness | HOLD |
| CarPlay | Separate constrained channel contract; no runtime target or entitlement | CHANNEL-HELD |
| Empirical usability and industry comparison | Static and local runtime specimens exist; no measured user task study | HOLD |

## Channel preservation

The change in this sitting is confined to the existing Experience/composer seam and its existing local object/receipt path:

- Wireframe infrastructure: remains the host for the composer and native file chooser.
- Processing: remains unchanged; no file bytes enter DOJO, hosted providers, `TodayProcessingPacket`, or chamber routes.
- Experience: now provides a real local file-selection action and a truthful `metadata only` state.

The file chooser is therefore a useful native capability without pretending that multimodal analysis exists. Choosing a file for local Capture is not the same operation as sending a file to a model.

The existing Google provider defect was also corrected within its current adapter: the catalog no longer defaults to the shut-down Gemini 2.0 Flash identifier, and the API key is sent in the documented header rather than the URL. A live key test is still required before calling the route working.

## Production sequence from the evidence

1. Complete the Mac-native local loop: text/file intake → clear object → receipt → review → continue.
2. Exercise external API-key model routes with bounded latency/error measurements before any local-model optimisation.
3. Add a separate multimodal processing seam only when its source, packet fields, and failure/HOLD states are explicit.
4. Add voice as its own native input/output capability and measure the round trip.
5. Evaluate CarPlay as a constrained phenotype after the Mac surface is excellent; do not transplant the three-panel Mac wireframe.
6. Run measured task observations and compare declared intention with actual usage/output before claiming production readiness.

## Sources

### Notion research

- <mention-page url="https://app.notion.com/p/a1dce9e2c6064ba291099d251b9ac380?pvs=204">Commercial AI Application Benchmark — Competitive Analysis & DOJO Suite Differentiation</mention-page>
- <mention-page url="https://app.notion.com/p/b6c1a7a8400e404b84f956c3912e56d2?pvs=204">Frontend Interface Strategy — Best-in-Class Multimodal UX Patterns</mention-page>
- <mention-page url="https://app.notion.com/p/37c146f06ec146b6958250aea8a88457?pvs=204">Apple Required Surface Matrix v0</mention-page>
- <mention-page url="https://app.notion.com/p/ea86e21ca40444508a7dbfb1d1f07fad?pvs=204">FIELD Matrix Surface Test — Today Screenshot v0</mention-page>
- <mention-page url="https://app.notion.com/p/9e8aec0e453c468e8c68c212bdcb814f?pvs=204">DOJO Development Diary — Implementation Log</mention-page>

### Local implementation evidence

- `/Users/field/DOJO-suite/docs/DOJO_TODAY_CHANNEL_SEPARATION_MAP_V0.md`
- `/Users/field/DOJO-suite/docs/DOJO_TODAY_SURFACE_ACTION_WIRING_MATRIX_V0.md`
- `/Users/field/DOJO-suite/Sources/DOJOApp/Views/DOJOTodaySurfaceView.swift`
- `/Users/field/◎Kings-Chamber/chronicle/DOJO_TODAY_LOCAL_ATTACHMENT_INTAKE_20260830.receipt.json`

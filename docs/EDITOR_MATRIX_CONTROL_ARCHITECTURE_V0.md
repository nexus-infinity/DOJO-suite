# FIELD Editor Matrix Control Architecture V0

Status: `IMPLEMENTED.PREVIEW_CONTROL_SURFACE`

## Object

The macOS DOJO editor surface is a behind-the-scenes matrix controller. It
selects a coordinate across independent axes and opens the relevant specialist
surface without allowing one lane to represent the whole FIELD.

## Non-collapse rule

The following axes remain independent:

1. **Input/acquisition channel**
   - no live input
   - microphone/audio
   - camera/vision
   - GPS/location
   - motion/IMU
   - wearable/somatic
   - device telemetry
   - environmental sensor
   - manual operator input
2. **Spatial relation**
   - `dedans` — inside
   - `dessus` — on top
   - `dessous` — below
   - `autour` — all around
3. **Augmentation return**
   - sight
   - sound
   - touch/haptic
4. **Projection archetype**
   - coach/cohort
   - copilot/HUD
   - training/readiness
   - mech/amplification
   - body/somatic
5. **Attention claim**
   - 0 ambient
   - 1 supportive
   - 2 directional
   - 3 interruptive
   - 4 stop/HOLD

The coordinate is descriptive editor state. It does not itself activate
hardware, publish a surface, grant authority, or write a Chronicle receipt.

## Functional boundaries

```text
hardware/device
    → HAL normalization
    → input-channel selection
    → spatial relation
    → ◉ Arkadaş real-time routing
    → ◼︎ DOJO cognitive/copilot orchestration
    → sight/sound/touch augmentation
    → projection archetype
    → attention claim
    → preview | HOLD | witnessed publish
```

- `HAL` normalizes hardware.
- `◉ Arkadaş` owns deterministic real-time routing.
- `◼︎ DOJO` owns cognitive/persona copilot orchestration.
- `◎ King’s Chamber` aligns and arbitrates; it is not the execution pipe.
- G6 remains the microphone/device laboratory and opens behind the matrix.
- Particle Board and WP-07 remain lifecycle/persistence witnesses; they are not
  promoted to the whole editor architecture.

## Implementation

- Typed contract:
  `Sources/DOJOShared/Contracts/EditorMatrixContract.swift`
- Primary editor surface:
  `Sources/DOJOApp/Views/EditorMatrixDashboardView.swift`
- Application entry:
  `Sources/DOJOApp/DOJOApp.swift`
- Contract tests:
  `Tests/DOJOSharedTests/EditorMatrixContractTests.swift`

## Acceptance criteria

- The matrix is the first window in the newly built application.
- Every axis can be selected independently.
- Default input is `No live input`.
- Default authority is `HOLD`.
- Selecting a coordinate remains preview-only.
- G6 opens as a named hardware channel, not the primary application.
- No publish or runtime claim occurs without a later witnessed action and
  receipt.

## Current HOLD

Live FIELD synchronization is not yet claimed. The S0–S11 landscape gate
reported BEAR `0.4`, and the cycle’s failure receipt could not write to
`/Users/field/logs/chronicle_s0_s11.jsonl` from the active sandbox.

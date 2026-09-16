# DOJO Today Surface v0 Benchmark Outer Shell

Timestamp: 2026-08-07T10:18:13+1000

## Objective

Create the smallest benchmark-quality ordinary-use outer shell for DOJO Today Surface v0.

Classification target:

```text
PARTIAL.BenchmarkOuterSurfaceCandidate
```

## Files Inspected

- `Sources/DOJOApp/DOJOApp.swift`
- `Sources/DOJOUI/BoundaryCapacityGlanceView.swift`
- `project.yml`

## Files Changed

- `Sources/DOJOApp/Views/DOJOTodaySurfaceView.swift`
- `Sources/DOJOApp/DOJOApp.swift`
- `DOJO-suite.xcodeproj/project.pbxproj`

Project membership was regenerated with `xcodegen generate` so the new Swift source is visible to the native Xcode project.

## Existing Entry Point Chosen

The first macOS `WindowGroup` was changed to:

```text
DOJO Today
```

The Apple Surface Matrix, Today / Capture static specimen, FIELD Editor Matrix, G6 Hardware Channel, and Cockpit Alpha remain secondary surfaces.

## New View Created

`DOJOTodaySurfaceView` was added as a separate macOS ordinary-use surface.

Primary visible structure:

- greeting / current mode
- large capture affordance
- action grid for capture, continue, review, attention
- recent thread / memory card
- attention card
- Boundary Capacity mini-status
- receipts/details behind disclosure

## Boundary Capacity

Boundary Capacity is carried as a read-only mini-status on the context rail.

The full shared `BoundaryCapacityGlanceView.reportingStubGlance(...)` remains behind disclosure.

No live probe, sync, runtime movement, portal round-trip, AKRON seal, or authority mutation was introduced.

## Build

Command:

```bash
xcodegen generate
```

Result:

```text
PASS
```

Command:

```text
Xcode BuildProject
```

Result:

```text
PASS
```

Build log:

```text
/var/folders/yl/b6mp9yw52sq_0mtrxrl2b3vr0000gs/T/ActionArtifacts/00AFD84C-76EF-4FDD-8403-B71F818C84E8/BuildProject/BuildProject-Log-20260807-015412.txt
```

## Visual Open Attempt

Attempted to open:

```text
/Users/field/Library/Developer/Xcode/DerivedData/DOJO-suite-chpxgmwqpwprgncvzevbccprkabz/Build/Products/Debug/DOJOApp.app
```

Result:

```text
HOLD.LiveDOJOTodayOperatorWindowWitness
```

LaunchServices returned:

```text
kLSNoExecutableErr
```

Direct executable launch exited with:

```text
code 134
```

No live screenshot was produced from the app window.

## Decision

```text
PARTIAL.BenchmarkOuterSurfaceCandidate
```

## Holds Preserved

- HOLD.BenchmarkSurfaceParityNotMet
- HOLD.WrongLayerExposed
- HOLD.LiveCockpitAlphaOperatorWindowWitness
- HOLD.LiveDOJOTodayOperatorWindowWitness
- HOLD.VisualEquivalenceToKodexXcodeVersion
- HOLD.ProductMaturity
- HOLD.RendererIdentity
- HOLD.ReleaseDissolveVisualReceipt
- HOLD.HomeProbeUnknown
- HOLD.HandoffWitnessUnknown
- HOLD.AuthorityCeilingUnknown
- HOLD.CanDriveNowUnknown

## Next Lawful Move

Fix or isolate the macOS app launch witness path so `DOJO Today` can be opened and screenshot from a live operator window.

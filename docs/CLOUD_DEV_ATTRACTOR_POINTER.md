# Cloud → Dev attractor pointer

**Repo**: `nexus-infinity/dojo-suite`  
**Canonical attractor (read this, do not fork a second landscape)**:

`nexus-infinity/field-macos-dojo` → `docs/CLOUD_DEV_ATTRACTOR_MURMURATION_AND_APPLE_PRODUCTION.md`

Cloud walk 2026-09-16 collapsed four “murmuration” meanings, Apple production CAN/CANNOT on Linux vs Mac, and competing “production ready” evals.

This file is a pointer only. Status, next actions, and the surface index live in the FIELD repo doc.

## On `main` / CI (pointer only)

This pointer is on `main` (merged PR #8 as `6574b58`). It remains a **pointer only**. A Mac `git pull origin main` receives it.

`Build and Test` (`macos-14`, Xcode 15.2, `swift build --configuration release`) was failing on pre-existing product compile errors, not on this pointer. The same branch now carries compile-only repairs in:

- `Sources/DOJOiOSApp/PacketListView.swift` — SwiftUI `LocalizedStringKey` cannot interpolate `prefix`/`suffix` Substring sequences
- `Sources/DOJOiOSApp/PacketQueue.swift` — `@MainActor` `packets[i]` passed `inout` into `async` `save`/`upload`
- `Sources/DOJOUI/DesignSystem/MurmorOrbitView.swift` — `#Preview` body did not return a `View` (AppKit vs SwiftUI `Preview` ambiguity)
- `Sources/DOJOUI/DesignSystem/ParticleBoardView.swift` — `@retroactive` is Swift 5.10+; Xcode 15.2 CI is Swift 5.9. `ForEach(..., id: \.self)` instead of a cross-module Identifiable conformance

Product GitHub Actions on commit `c4a06a0`:

- `Build and Test` / `test` (macos-14, Xcode 15.2, `swift build --configuration release`) — **green** (run `35093751140`)
- `CI` / `build-and-test` — **green** (run `35093751258`)

Linux cloud cannot run `swift`. That is CI evidence only — not Xcode/device/G6 proof.

Remaining UNSTABLE: Vercel project `v0-dojo-suite` preview still fails. That is a web deploy, not Apple production. Do not drive-by refactor Swift for it. FIELD attractor is also on `main` (merged PR #27 as `c754c29`). Order was #8 then #27. End state is correct.

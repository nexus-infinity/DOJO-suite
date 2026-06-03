# UX Audit — DOJOApp Surface Gap
**Date**: 2026-06-03  
**Status**: Partially resolved (ChamberRail wired; benchmark reframed)

---

## What the user saw

DOJOApp launched to a completely black window. Only a `Type a message...` input bar was visible at the bottom. No chamber rail, no BEAR score, no chamber signals. Nothing.

This is what was shown to an external evaluator (Claude desktop) as the "benchmark surface."

---

## Root cause

`ChamberRail` and `ChamberHealthMonitor` were implemented and sitting in:
- `Sources/DOJOApp/Views/ChamberRail.swift`
- `Sources/DOJOApp/Controllers/ChamberHealthMonitor.swift`

Neither was ever connected to the view hierarchy. `DOJOApp.swift` rendered `ContentView()` → `MinimalChatView()` — a plain chat input with no shell around it.

The layout was never assembled.

---

## What was frustrating

1. **Benchmark was defined on a non-existent surface.** The S0 benchmark (watch face → Claude desktop) made no sense. When reframed to DOJOApp, the app had nothing to show. The benchmark infrastructure was real but the surface it was measuring was empty.

2. **The app looked broken by default.** A user launching DOJOApp for the first time saw a black void. There was no indication anything was loading or that chambers exist.

3. **Components existed but weren't connected.** ChamberRail was a complete, well-written component — it just wasn't wired. This is a recurring pattern: pieces built in isolation, integration deferred.

---

## Fix applied (2026-06-03)

`DOJOApp.swift` updated to:
```swift
HStack(spacing: 0) {
    ChamberRail(health: health)
    Divider()
    ContentView()
}
```

`ChamberHealthMonitor` instantiated as `@StateObject` on the app root. Window width expanded from 720 → 792 to accommodate the 72pt rail.

---

## Remaining gaps

- Chamber health depends on `SpinningTopClient` reaching live chamber endpoints. If MCP chambers are not running, all signals will show `.offline` / `.unknown`. The rail will be visible but dim.
- No loading/connecting state shown while the first `poll()` is in flight (~15s window where nothing appears).
- Benchmark S1–S3 (chamber state read) can now proceed once the app is rebuilt and a live screenshot captured.

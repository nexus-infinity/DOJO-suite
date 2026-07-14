# Speech Lifecycle Runtime Witness — 2026-07-12

**Status**: **HOLD** — path not exercised  
**Build**: PASS (DOJOApp compiles)  
**Runtime witness**: **FAIL** (launch timeout, not speech crash)

## Attempted code path

```
CopilotEngine.process(input:)
  → DOJOFieldCoordinator.handleMessage(_:)
  → speakResponse(_:as:)
```

**UI path used**: none (RunCodeSnippet public code path only)

## Parameters

| Field | Value |
|-------|-------|
| `audioMode` | intended `.full` (default) — **not reached** |
| Speech started | not verified |
| Speech finished | not verified |
| Cancel/interruption | not tested |

## Failure (launch, not speech)

```
AppLaunchTimeoutError: Failed to launch app "DOJOApp.app" in reasonable time
Bundle ID: org.field.dojo
Path: .../DerivedData/DOJO-suite-chpxgmwqpwprgncvzevbccprkabz/Build/Products/Debug/DOJOApp.app
```

No new speech crash stack. `speakResponse` / `AVSpeechSynthesizer` delegate path was never entered.

## Scope boundary (confirmed)

No packet, AKRON, storage, or Portal Integrity Loop files touched during this verification step.

## Pass statement

**Not applicable.** Cannot state “Speech lifecycle runtime witness passed.”

## Required-next-evidence

1. **Manual Xcode Run** (⌘R) on My Mac — not RunCodeSnippet — then trigger chat/TTS via UI or debugger breakpoint at `speakResponse`.
2. **Or** extend `HALAudioPipelineTests` with injectable `AVSpeechSynthesizer` mock to witness start/finish/cancel without full app launch.
3. **Or** increase Xcode test launch timeout if snippet launch is required.

## Related code

- `Sources/DOJOShared/HAL/DOJOFieldCoordinator.swift` — `speakResponse`, synthesizer delegates
- `Tests/DOJOSharedTests/HAL/HALAudioPipelineTests.swift` — ducking delegate smoke only; no TTS lifecycle assertion yet

**Seal**: `intentionally_unsealed` — awaiting runtime evidence

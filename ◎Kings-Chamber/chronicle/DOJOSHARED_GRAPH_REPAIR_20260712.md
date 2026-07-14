# DOJOShared Graph Repair - 2026-07-12

## Files changed

- `Package.swift`
- `project.yml`

## Package dependency shape

Before:

```swift
.target(name: "FieldKit", dependencies: [], path: "Sources/FieldKit")
```

After:

```swift
.target(name: "FieldKit", dependencies: ["DOJOShared"], path: "Sources/FieldKit")
```

`DOJOShared` is a target in the same `Package.swift`, not a separate local package dependency.

## Xcode project state

`Sources/DOJOShared/HAL/SealedVoiceObject.swift` exists on disk and defines:

- `SealedVoiceObject`
- `SealedVoiceObjectStore`
- lifecycle / authority / copy / export policy enums

Xcode still does not show `SealedVoiceObject.swift` in the `DOJOShared/HAL` group, so the native Xcode target source phase still needs target membership updated from Xcode UI.

## Remaining required Xcode action

Add `Sources/DOJOShared/HAL/SealedVoiceObject.swift` to:

- `DOJOShared` target sources
- `DOJOiOSApp` target sources only while `DOJOiOSApp` continues compiling `Sources/DOJOShared/HAL` directly

Do not create `DOJOUI`.
Do not move `PacketRepository`, `PacketFileStore`, or `AKRONClient`.
Do not make `DOJOShared` depend on `FieldKit`.

## Build

Not rerun after the Xcode target-membership block, because the visible Xcode project graph still omits `SealedVoiceObject.swift` and would reproduce the same unresolved-symbol errors.

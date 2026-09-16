# DOJO Today M1 — Hosted Multimodel App Loop

**Timestamp:** 2026-08-07T14:15:00+1000 (approx)
**Build:** `xcodegen generate` + `xcodebuild -scheme DOJOApp` → **BUILD SUCCEEDED**

## Decision pins

| Pin | Status |
|-----|--------|
| PASS.FirstScreenLayerSeparation | retained |
| PARTIAL.PanelBoundaryFunctionality | retained (structural + test chips; interactive witness still HOLD) |
| PARTIAL.SettingsBenchmarkParity | improved for Models + API keys |
| PARTIAL.GeneratedObjectShells | Answer path is live-capable |
| HOLD.LiveBoundaryClickThroughWitness | human GUI still required |
| PARTIAL.RealMultimodelAppLoop | M1 code path present; needs live key + call |
| HOLD.LocalModels | disabled placeholder |
| HOLD.FIELDMemory | not integrated |

## Quick boundary witness (pre-M1)

| Check | Result |
|-------|--------|
| Collapse/restore left controls in source | Present |
| Collapse/restore right controls in source | Present |
| Settings section switch | Present |
| Proof sheet | Present |
| Seed / type answer path | Present (seed offline + Continue hosted) |
| Visible structural break | **None observed** → proceeded to M1 |

Interactive click-through remains `HOLD.LiveBoundaryClickThroughWitness`.

## Files

### Created
- `Sources/DOJOApp/Services/M1/HostedProviderCatalog.swift`
- `Sources/DOJOApp/Services/M1/APIKeychainStore.swift`
- `Sources/DOJOApp/Services/M1/HostedChatClient.swift`
- `Sources/DOJOApp/Services/M1/GeneratedObjectModels.swift`
- `Sources/DOJOApp/Services/M1/GeneratedObjectStore.swift`

### Changed
- `Sources/DOJOApp/Views/DOJOTodaySurfaceView.swift` — M1 loop wired
- `DOJO-suite.xcodeproj` — xcodegen include M1 sources

## Scope kept out
- FIELD memory
- Local models (UI disabled)
- FIELD governance primary UI
- Runtime/sync/authority claims
- Fake test-connection success

## Live test
1. Launch DOJOApp → DOJO Today
2. Settings → API keys → paste key → Save (Keychain)
3. Test connection (real HTTP; failure surfaces error text)
4. Composer: pick provider/model → type → Continue
5. Answer object appears in Generated objects
6. Select → right Object context updates
7. Save → Application Support JSON
8. Export → clipboard + Documents/DOJO-Exports/*.md
9. Continue with object selected → prior body used as context

Store path: `~/Library/Application Support/org.field.dojo/generated_objects.json`
Keychain service: `org.field.dojo.m1.api-keys`

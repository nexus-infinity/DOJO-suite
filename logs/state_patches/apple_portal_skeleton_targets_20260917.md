# Apple Portal Skeleton Targets Receipt

timestamp: 2026-09-17T03:12:00+10:00
object: AppleRequiredSurfaceMatrix.v0
state: PARTIAL.CompilingPortalSkeletons
authorityCeiling: portal-only; no DOJO runtime promotion; no vehicle control; no biometric authority; Apple TV is not PULSE

| Surface | Implementation receipt | State |
|---|---|---|
| macOS | Existing DOJOApp family | BOUNDED |
| iPhone | Existing DOJOiOSApp | BUILDS; device proof HOLD |
| iPad | Named in the DOJOiOSApp Apple portals card; shares the iOS binary | DESTINATION NAMED; device proof HOLD |
| Watch | DOJOWatchApp one-card cue portal | BUILDS; biometric authority HOLD |
| CarPlay | ParkedCarPlaySceneDelegate compiles inside DOJOiOSApp | ENTITLEMENT HOLD; scene registration HOLD; runtime HOLD; vehicle control FORBIDDEN |
| Apple TV | DOJOTVApp one-card room portal | SIMULATOR BUILD PASS; device signing HOLD; runtime HOLD; not PULSE |

Validation:

- XcodeGen graph generated with 10 shared schemes.
- DOJOWatchApp: PASS on generic watchOS device build destination.
- DOJOTVApp: PASS on generic tvOS simulator build destination.
- DOJOTVApp physical-device signing: HOLD because no tvOS provisioning profile/device receipt exists.
- DOJOiOSApp: PASS on the selected iPhone destination.
- DOJOApp test plan: 415 total; 401 passed; 0 failed; 14 explicitly skipped.
- Xcode live diagnostics: zero issues in all new and modified Swift surface files.

The CarPlay adapter is deliberately not registered in `UIApplicationSceneManifest`, and no CarPlay entitlement was added. Those omissions are the enforcement mechanism for the runtime HOLD, not unfinished hidden activation.

The prior HealthKit-backed `OBIWANFaceView.swift` remains in source history but is excluded from the Watch target. The compiling Watch portal neither requests biometric access nor claims observer authority.

# WP-07 Restart Witness Receipt

timestamp: 2026-07-23T16:32:55Z
boardSource: seeded
expectedValue: UNKNOWN
preRestartHash: UNKNOWN
postRestartHash: UNKNOWN
result: HOLD
holdReasons:
- HOLD.VisualAutomationUnavailable
- HOLD.ScreenCaptureUnavailable
- HOLD.RequiredExternalReceiptPathNotWritable
- HOLD.WP07TargetNotEdited
- HOLD.WP07WitnessFileMissing

notes:
- macOS DOJOApp target built and launched from SwiftPM.
- Existing Xcode-launched DOJOApp process was present.
- Live cockpit surface could not be observed from this shell: System Events returned -10827 and screencapture could not create an image from the display.
- Persisted cockpit board inspection showed Cockpit v0 seeded content with cell [2,2] still empty.
- /Users/field/Library/Application Support/DOJO/wp07_witness.json was not present.
- This fallback receipt is stored in-repo because /Users/field/logs/state_patches could not be created from the sandbox.

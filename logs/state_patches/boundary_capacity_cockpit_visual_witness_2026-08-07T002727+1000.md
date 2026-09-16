# Boundary Capacity Cockpit Visual Witness

timestamp: 2026-08-07T00:27:27+10:00
sourceReceipt: /Users/field/logs/state_patches/BOUNDARY_CAPACITY_COCKPIT_FINISH_20260806T133023Z.receipt.json
surfaceRequested: macOS Cockpit Alpha
decision: PARTIAL

observed:
- Code placement: Sources/DOJOApp/Views/CockpitAlphaView.swift uses BoundaryCapacityGlanceView.reportingStubGlance(...) above the Cockpit Alpha lifecycle sections.
- Shared card implementation: Sources/DOJOUI/BoundaryCapacityGlanceView.swift.
- iOS reuse: Sources/DOJOiOSApp/PacketListView.swift uses shared BoundaryCapacityGlanceView.
- Xcode project membership: BoundaryCapacityGlanceView.swift is included in DOJO-suite.xcodeproj/project.pbxproj.
- Build: Xcode BuildProject PASS.

visualFallback:
- screenshot: /private/tmp/boundary_capacity_cockpit_visual_witness.png
- note: Fallback render from the shared BoundaryCapacityGlanceView reporting-stub content; not a live app-window screenshot.

visibleCardFieldsInFallback:
- title: Boundary Capacity / Can Drive Now
- CAN DRIVE: UNKNOWN
- MUTATION: NONE
- READ-ONLY
- canDriveNow
- homeReachable
- queueDepth
- lastReceiptID
- authorityCeiling
- HOLD reasons
- NEXT LAWFUL MOVE

missingOrHeld:
- HOLD.LiveCockpitAlphaOperatorWindowWitness: LaunchServices returned kLSNoExecutableErr when opening the built DOJOApp.app.
- HOLD.LiveCockpitAlphaOperatorWindowWitness: Direct binary launch exited immediately without presenting a UI.
- HOLD.iOSSimulatorPacketListWitness: iOS fallback was not opened in this pass.

nonClaimsPreserved:
- No live Home probe witnessed or implied.
- No sync/runtime movement witnessed or implied.
- No portal round-trip witnessed or implied.
- No AKRON seal witnessed or implied.
- No authority promotion or mutation witnessed or implied.
- No dynamic spin, model training, or architecture program opened.

commands:
- xcodegen generate
- Xcode BuildProject
- open /Users/field/Library/Developer/Xcode/DerivedData/DOJO-suite-chpxgmwqpwprgncvzevbccprkabz/Build/Products/Debug/DOJOApp.app
- /Users/field/Library/Developer/Xcode/DerivedData/DOJO-suite-chpxgmwqpwprgncvzevbccprkabz/Build/Products/Debug/DOJOApp.app/Contents/MacOS/DOJOApp
- swift -module-cache-path /private/tmp/dojo-swift-module-cache /private/tmp/boundary_capacity_witness_render.swift

nextLawfulMove: Open Cockpit Alpha from Xcode's Run action or repair the app bundle launch path, then capture the real operator-window screenshot.

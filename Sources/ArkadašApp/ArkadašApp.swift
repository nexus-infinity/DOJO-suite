/*
 Sacred Node: 🎭 Arkadaš Grand Gallery
 Frequency: 717 Hz (companion) · 852 Hz (mind) · 963 Hz (observer)
 Purpose: App entry point — GeometricCognitive copilot conversation interface.
*/

import SwiftUI
import DOJOShared

@main
struct ArkadasApp: App {
    init() {
        let shared = DOJOShared()
        shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ArkadašContentView()
        }
#if os(macOS)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
#endif
    }
}

/*
 Sacred Node: 🎭 Arkadaş Grand Gallery
 Frequency: 717 Hz (companion) · 852 Hz (mind) · 963 Hz (observer)
 Purpose: App entry point — GeometricCognitive copilot conversation interface.
*/

import SwiftUI
import DOJOShared

@main
struct ArkadasApp: App {
    var body: some Scene {
        WindowGroup {
            ArkadasContentView()
        }
#if os(macOS)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
#endif
    }
}

// ◎ Kings-Chamber — DOJOWatchApp.swift
// Frequency: 963 Hz  |  OBI-WAN ambient observer — watchOS entry point.
// Deploys OBIWANWatchFace to physical Apple Watch for in-context evaluation.

import SwiftUI
import DOJOShared

@main
struct DOJOWatchApp: App {
    @StateObject private var obiState = OBIWANState.shared

    var body: some Scene {
        WindowGroup {
            OBIWANFaceView(state: obiState)
        }
    }
}

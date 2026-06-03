import SwiftUI
import AppKit
import DOJOShared

@main
struct DOJOApp: App {
    @StateObject private var health = ChamberHealthMonitor()

    init() {
        Task.detached(priority: .background) {
            let shared = DOJOShared()
            shared.initialize()
        }
    }

    var body: some Scene {
        WindowGroup {
            HStack(spacing: 0) {
                ChamberRail(health: health)
                Divider()
                DOJOChatView(health: health)
            }
            .onAppear {
                NSApp.activate(ignoringOtherApps: true)
            }
        }
        .defaultSize(width: 792, height: 600)
    }
}

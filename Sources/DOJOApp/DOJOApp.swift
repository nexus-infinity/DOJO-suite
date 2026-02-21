import SwiftUI
import DOJOShared
import DOJOUI

@main
struct DOJOApp: App {
    init() {
        let shared = DOJOShared()
        shared.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 4) {
                Text("◼︎ DOJO")
                    .font(.system(size: 24, weight: .bold))
                Text("Manifestation Orchestrator • 741 Hz")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color(NSColor.controlBackgroundColor))
            
            // Chat interface
            MinimalChatView()
        }
        .frame(minWidth: 600, minHeight: 500)
    }
}

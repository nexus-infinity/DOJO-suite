import SwiftUI
import DOJOShared
import DOJOUI

#if canImport(AppKit)
private let secondaryLabelColor: Color = Color(nsColor: .secondaryLabelColor)
private let controlBackgroundColor: Color = Color(nsColor: .controlBackgroundColor)
#elseif canImport(UIKit)
private let secondaryLabelColor: Color = Color(UIColor.secondaryLabel)
private let controlBackgroundColor: Color = Color(UIColor.secondarySystemBackground)
#else
private let secondaryLabelColor: Color = .secondary
private let controlBackgroundColor: Color = .secondary
#endif

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
                    .foregroundColor(secondaryLabelColor)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                {
                    controlBackgroundColor
                }()
            )
            
            // Chat interface
            MinimalChatView()
        }
        .frame(minWidth: 600, minHeight: 500)
    }
}


import SwiftUI
import DOJOShared

@main
struct DojoLinkApp: App {
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
        VStack(spacing: 20) {
            Text("◆ DojoLink")
                .font(.system(size: 40, weight: .bold))
            Text("Mobile Field Interface (717 Hz)")
                .font(.title2)
            
            Button("Sync Field Data") {
                print("DojoLink: Syncing field data at 717 Hz")
            }
            .buttonStyle(.borderedProminent)
            
            Text("Shared version: \(DOJOShared.version)")
                .font(.caption)
        }
        .frame(minWidth: 500, minHeight: 400)
        .padding()
    }
}

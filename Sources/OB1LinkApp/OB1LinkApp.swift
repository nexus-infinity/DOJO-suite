import SwiftUI
import DOJOShared

@main
struct OB1LinkApp: App {
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
            Text("● OB1Link")
                .font(.system(size: 40, weight: .bold))
            Text("Observer Consciousness (963 Hz)")
                .font(.title2)
            
            Button("Witness State") {
                print("OB1Link: Witnessing crown chakra state at 963 Hz")
            }
            .buttonStyle(.borderedProminent)
            
            Text("Shared version: \(DOJOShared.version)")
                .font(.caption)
        }
        .frame(minWidth: 500, minHeight: 400)
        .padding()
    }
}

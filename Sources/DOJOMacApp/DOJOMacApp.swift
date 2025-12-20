import SwiftUI
import DOJOShared

@main
struct DOJOMacApp: App {
    init() {
        let shared = DOJOShared()
        shared.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.automatic)
    }
}

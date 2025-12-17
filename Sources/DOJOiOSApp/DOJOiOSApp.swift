import SwiftUI
import DOJOShared

@main
struct DOJOiOSApp: App {
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

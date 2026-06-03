import SwiftUI
import DOJOShared

// Platform-adaptive entry for the DOJOUI library.
// macOS  → MinimalChatView (direct streaming chat)
// iOS    → NavigationStack wrapping MinimalChatView

public struct ContentView: View {
    public init() {}

    public var body: some View {
        #if os(macOS)
        MinimalChatView()
        #else
        NavigationStack {
            MinimalChatView()
                .navigationTitle("◼︎ DOJO")
                .navigationBarTitleDisplayMode(.inline)
        }
        #endif
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

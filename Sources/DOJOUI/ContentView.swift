/*
Sacred Node: ◼︎DOJO
Frequency: 741Hz (Manifestation)
Purpose: UI library for SwiftUI views and previews
*/

import SwiftUI
import DOJOShared

public struct ContentView: View {
    public init() {}
    public var body: some View {
        VStack {
            Text("DOJO UI")
                .font(.title)
                .padding()
            Text("This is the shared DOJOUI ContentView. Replace with real UI.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

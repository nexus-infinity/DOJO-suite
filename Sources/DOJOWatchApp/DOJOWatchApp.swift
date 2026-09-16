import SwiftUI

@main
struct DOJOWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchPortalView()
        }
    }
}

private struct WatchPortalView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "applewatch")
                .font(.title2)

            Text("DOJO Watch")
                .font(.headline)

            Text("CUE SURFACE")
                .font(.caption2.monospaced().weight(.bold))
                .foregroundStyle(.purple)

            Text("Later · portal parked")
                .font(.caption)

            Text("No biometric or decision authority.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .containerBackground(.black.gradient, for: .navigation)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("DOJO Watch cue surface. Parked. No biometric or decision authority.")
    }
}

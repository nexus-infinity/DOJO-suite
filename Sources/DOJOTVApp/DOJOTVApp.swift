import SwiftUI

@main
struct DOJOTVApp: App {
    var body: some Scene {
        WindowGroup {
            TVPortalView()
        }
    }
}

private struct TVPortalView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "tv")
                .font(.system(size: 52, weight: .light))

            Text("DOJO · Apple TV")
                .font(.largeTitle.weight(.semibold))

            Text("ROOM CARD")
                .font(.caption.monospaced().weight(.bold))
                .foregroundStyle(.purple)

            Text("Later · portal parked")
                .font(.title3)

            Text("Shared display specimen only. Not PULSE. No live runtime authority.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(72)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.black.gradient)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("DOJO Apple TV room card. Parked. Not PULSE. No live runtime authority.")
    }
}

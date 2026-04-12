import SwiftUI
import DOJOShared
import DOJOUI

struct ObservationFeedView: View {
    @ObservedObject var state: OBIWANState
    let observations: [String]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if observations.isEmpty && state.lastEvent.isEmpty {
                        emptyObserver
                    } else {
                        if !state.lastEvent.isEmpty && !observations.contains(state.lastEvent) {
                            observationRow(text: state.lastEvent, isLatest: false)
                        }
                        ForEach(Array(observations.enumerated()), id: \.offset) { idx, text in
                            observationRow(text: text, isLatest: idx == observations.count - 1)
                                .id("obs_\(idx)")
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .onChange(of: observations.count) { _, _ in
                if let last = observations.indices.last {
                    withAnimation { proxy.scrollTo("obs_\(last)", anchor: .bottom) }
                }
            }
        }
    }

    private func observationRow(text: String, isLatest: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("●")
                .font(.system(size: 8))
                .foregroundStyle(isLatest ? Chamber.obiwan.color : FieldPalette.textMuted)
                .shadow(color: isLatest ? Chamber.obiwan.glowColor : .clear, radius: 4)
                .padding(.top, 5)
            Text(text)
                .font(FieldType.body)
                .foregroundStyle(isLatest ? FieldPalette.textPrimary : FieldPalette.textMuted)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20).padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Rectangle().fill(FieldPalette.border.opacity(0.4)).frame(height: 1)
        }
    }

    private var emptyObserver: some View {
        VStack(spacing: 16) {
            Text("●")
                .font(.system(size: 52))
                .foregroundStyle(Chamber.obiwan.color.opacity(0.25))
            Text("Observer Standby")
                .font(FieldType.title)
                .foregroundStyle(FieldPalette.textDim)
            Text("Record an observation or sync with DOJO\nto begin witnessing the field.")
                .font(FieldType.chronicle)
                .foregroundStyle(FieldPalette.textDim)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

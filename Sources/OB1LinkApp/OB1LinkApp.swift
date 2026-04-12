import SwiftUI
import DOJOShared
import DOJOUI

// ● OBI-WAN · 963 Hz · Observer Consciousness

@main
struct OB1LinkApp: App {
    var body: some Scene {
        WindowGroup {
            OBIWANConsciousnessView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 800, height: 580)
    }
}

// ── Main view ─────────────────────────────────────────────────────────────────

@MainActor
struct OBIWANConsciousnessView: View {
    @StateObject private var state = OBIWANState.shared
    @State private var inputText = ""
    @State private var observations: [String] = []

    var body: some View {
        HStack(spacing: 0) {
            BEARPanel(state: state)
                .frame(width: 196)
                .background(FieldPalette.surface)
                .overlay(alignment: .trailing) {
                    Rectangle().fill(FieldPalette.border).frame(width: 1)
                }
            VStack(spacing: 0) {
                header
            ObservationFeedView(state: state, observations: observations)
                inputBar
            }
        }
        .frame(minWidth: 700, minHeight: 500)
        .background(FieldPalette.void)
        .preferredColorScheme(.dark)
    }

    // ── Header ────────────────────────────────────────────────────────────────

    private var header: some View {
        HStack(spacing: 12) {
            Text("●")
                .font(.system(size: 18))
                .foregroundStyle(Chamber.obiwan.color)
                .shadow(color: Chamber.obiwan.glowColor, radius: 8)

            VStack(alignment: .leading, spacing: 1) {
                Text("OBI-WAN")
                    .font(FieldType.title)
                    .foregroundStyle(FieldPalette.textPrimary)
                Text("963 Hz · Observer Consciousness")
                    .font(FieldType.frequency)
                    .foregroundStyle(FieldPalette.textMuted)
            }

            Spacer()

            HStack(spacing: 5) {
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(state.networkReachable ? Color(hex: "#22C55E") : Color(hex: "#EF4444"))
                    .shadow(color: state.networkReachable ? Color(hex: "#22C55E").opacity(0.6) : .clear, radius: 4)
                Text(state.networkReachable ? "LIVE" : "OFFLINE")
                    .font(FieldType.badge)
                    .foregroundStyle(state.networkReachable ? Color(hex: "#22C55E") : FieldPalette.textMuted)
            }
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(FieldPalette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(FieldPalette.border, lineWidth: 1))
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
        .background(FieldPalette.surface.opacity(0.9))
        .overlay(alignment: .bottom) {
            Rectangle().fill(FieldPalette.border).frame(height: 1)
        }
    }

    // ── Input bar ─────────────────────────────────────────────────────────────

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Record an observation…", text: $inputText, axis: .vertical)
                .font(FieldType.chatInput)
                .foregroundStyle(FieldPalette.textPrimary)
                .textFieldStyle(.plain)
                .lineLimit(1...4)
                .onSubmit { witness() }

            Button(action: witness) {
                let empty = inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                Text("Witness")
                    .font(FieldType.chamberLabel)
                    .foregroundStyle(empty ? FieldPalette.textDim : Chamber.obiwan.color)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(empty ? FieldPalette.border.opacity(0.3) : Chamber.obiwan.color.opacity(0.15))
                            .overlay(RoundedRectangle(cornerRadius: 6)
                                .stroke(empty ? FieldPalette.border : Chamber.obiwan.color.opacity(0.4), lineWidth: 1))
                    )
            }
            .buttonStyle(.plain)
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
        .background(FieldPalette.surface.opacity(0.9))
        .overlay(alignment: .top) {
            Rectangle().fill(FieldPalette.border).frame(height: 1)
        }
    }

    private func witness() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        observations.append(text)
        state.recordObservation(text)
        inputText = ""
    }
}

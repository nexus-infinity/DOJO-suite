import SwiftUI
import DOJOShared
import DOJOUI

// BEARPanel owns the left sidebar of OBIWANConsciousnessView:
// BEAR alignment ring, Tesla 3-6-9 phase selector, observation status, and Sync DOJO button.
struct BEARPanel: View {
    @ObservedObject var state: OBIWANState
    @State private var isSyncing = false
    @State private var syncFeedback: String? = nil

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // BEAR alignment ring
            ZStack {
                Circle().stroke(FieldPalette.border, lineWidth: 5).frame(width: 96, height: 96)
                Circle()
                    .trim(from: 0, to: state.alignment)
                    .stroke(FieldPalette.bearRing(state.alignment),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 96, height: 96)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: FieldPalette.bearRing(state.alignment).opacity(0.5), radius: 6)
                    .animation(.easeInOut(duration: 0.8), value: state.alignment)
                VStack(spacing: 0) {
                    Text(String(format: "%.3f", state.alignment))
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(FieldPalette.bearRing(state.alignment))
                    Text("BEAR")
                        .font(FieldType.frequency)
                        .foregroundStyle(FieldPalette.textMuted)
                }
            }

            // Tesla 3-6-9 phase indicator
            VStack(spacing: 8) {
                Text("PHASE")
                    .font(FieldType.frequency)
                    .foregroundStyle(FieldPalette.textMuted)
                HStack(spacing: 6) {
                    ForEach([3, 6, 9], id: \.self) { phase in
                        Button { state.setPhase(phase) } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 34, height: 34)
                                    .foregroundStyle(state.currentPhase == phase
                                        ? Chamber.obiwan.color.opacity(0.2)
                                        : FieldPalette.border.opacity(0.3))
                                    .overlay(Circle().stroke(
                                        state.currentPhase == phase ? Chamber.obiwan.color : FieldPalette.border,
                                        lineWidth: 1.5))
                                Text("\(phase)")
                                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(state.currentPhase == phase
                                        ? Chamber.obiwan.color : FieldPalette.textDim)
                            }
                            .shadow(color: state.currentPhase == phase ? Chamber.obiwan.glowColor : .clear, radius: 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Text("Tesla cycle  3 → 6 → 9")
                    .font(FieldType.frequency)
                    .foregroundStyle(FieldPalette.textDim)
            }

            // Observation status pulse
            VStack(spacing: 4) {
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(state.isObserving ? Chamber.obiwan.color : FieldPalette.textDim)
                    .shadow(color: state.isObserving ? Chamber.obiwan.glowColor : .clear, radius: 5)
                Text(state.isObserving ? "OBSERVING" : "STANDBY")
                    .font(FieldType.frequency)
                    .foregroundStyle(state.isObserving ? Chamber.obiwan.color : FieldPalette.textMuted)
            }

            Spacer()

            // Sync DOJO button
            Button {
                Task {
                    isSyncing = true
                    await state.syncWithDojo()
                    syncFeedback = state.isObserving ? "✓ Synced" : "✗ Failed"
                    isSyncing = false
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    syncFeedback = nil
                }
            } label: {
                HStack(spacing: 6) {
                    if isSyncing {
                        ProgressView().scaleEffect(0.5).tint(FieldPalette.textMuted)
                    } else {
                        Text("◼︎").font(.system(size: 11)).foregroundStyle(Chamber.dojo.color)
                    }
                    Text(isSyncing ? "Syncing…" : (syncFeedback ?? "Sync DOJO"))
                        .font(FieldType.chamberLabel)
                        .foregroundStyle(syncFeedback?.hasPrefix("✓") == true
                            ? Color(hex: "#22C55E") : FieldPalette.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(FieldPalette.border.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(FieldPalette.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(isSyncing)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }
}

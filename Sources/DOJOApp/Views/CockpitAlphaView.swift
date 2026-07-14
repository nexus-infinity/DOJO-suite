import SwiftUI
import DOJOUI

// MARK: - Cockpit Alpha — Truthful Packet Lifecycle Surface
// COCKPIT-ALPHA-001 · 2026-07-13
// Snapshot: what is promoted, what is pending, what must not be overclaimed.
// All state is hardcoded truth at time of build — no live polling.

// MARK: - State Model

private enum CockpitState {
    case promoted    // receipt-backed, tests passing
    case pending     // work acknowledged, not yet wired
    case safe        // direction correct, naming not canon
    case hold        // must not be claimed until gate passes

    var accentColor: Color {
        switch self {
        case .promoted: return Color(hex: "#22C55E")
        case .pending:  return Color(hex: "#F59E0B")
        case .safe:     return Color(hex: "#06B6D4")
        case .hold:     return Color(hex: "#EF4444")
        }
    }

    var backgroundColor: Color {
        switch self {
        case .promoted: return Color(hex: "#22C55E").opacity(0.05)
        case .pending:  return Color(hex: "#F59E0B").opacity(0.04)
        case .safe:     return Color(hex: "#06B6D4").opacity(0.04)
        case .hold:     return Color(hex: "#EF4444").opacity(0.04)
        }
    }
}

private struct CockpitEntry: Identifiable {
    let id = UUID()
    let glyph: String
    let label: String
    let state: CockpitState
    let detail: String
    let subDetail: String?
}

// MARK: - View

struct CockpitAlphaView: View {

    private let sections: [(String, CockpitState, [CockpitEntry])] = [
        ("PROMOTED", .promoted, [
            CockpitEntry(
                glyph: "◉",
                label: "VOICE-S0 sealed voice tests",
                state: .promoted,
                detail: "9 / 9 pass",
                subDetail: "commit 29103f6 · SealedVoiceObjectTests.swift"
            ),
            CockpitEntry(
                glyph: "◉",
                label: "Native Xcode graph receipt",
                state: .promoted,
                detail: "DOJOSharedTests wired · pbxproj regenerated",
                subDetail: "commit 37fd3fa · project.yml + xcodegen"
            ),
        ]),
        ("RECEIPT PENDING", .pending, [
            CockpitEntry(
                glyph: "○",
                label: "AKRON live receipt",
                state: .pending,
                detail: "not wired in this lane",
                subDetail: "voice transport handoff pending live AKRON run"
            ),
        ]),
        ("SAFE / NOT CANON", .safe, [
            CockpitEntry(
                glyph: "◻",
                label: "Packet boundary",
                state: .safe,
                detail: "direction: FieldKit → DOJOShared  ✓",
                subDetail: "naming not canon · PACKET-BOUNDARY-DECISION-001 observed"
            ),
        ]),
        ("HOLD", .hold, [
            CockpitEntry(
                glyph: "⊠",
                label: "Pulse",
                state: .hold,
                detail: "not voice transport · not yet defined in code",
                subDetail: "do not define until voice transport gate clears"
            ),
            CockpitEntry(
                glyph: "⊠",
                label: "ParticleBoard",
                state: .hold,
                detail: "prototype only",
                subDetail: "visual approval pending · WP-07 not promoted"
            ),
            CockpitEntry(
                glyph: "⊠",
                label: "G6 Hardware Gate",
                state: .hold,
                detail: "partial graph · no hardware receipt",
                subDetail: "G6UI.swift + Sources/DOJOShared/G6/ untracked"
            ),
        ]),
    ]

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                header
                separator
                ForEach(sections, id: \.0) { title, sectionState, entries in
                    sectionBlock(title: title, sectionState: sectionState, entries: entries)
                }
                footer
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(FieldPalette.void)
        .frame(minWidth: 560, minHeight: 440)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("COCKPIT ALPHA")
                .font(.system(.title3, design: .monospaced, weight: .bold))
                .foregroundStyle(FieldPalette.textPrimary)
            Text("Voice Packet Lifecycle  ·  Truthful Surface  ·  2026-07-13")
                .font(FieldType.frequency)
                .foregroundStyle(FieldPalette.textMuted)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var separator: some View {
        Rectangle()
            .fill(FieldPalette.border)
            .frame(height: 1)
    }

    // MARK: - Section

    private func sectionBlock(title: String, sectionState: CockpitState, entries: [CockpitEntry]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section label row
            HStack(spacing: 0) {
                Rectangle()
                    .fill(sectionState.accentColor)
                    .frame(width: 3)
                Text(title)
                    .font(FieldType.frequency)
                    .foregroundStyle(sectionState.accentColor)
                    .padding(.leading, 12)
                    .padding(.vertical, 8)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(FieldPalette.surface)

            ForEach(entries) { entry in
                entryRow(entry)
            }

            Rectangle()
                .fill(FieldPalette.border.opacity(0.5))
                .frame(height: 1)
        }
    }

    // MARK: - Entry Row

    private func entryRow(_ entry: CockpitEntry) -> some View {
        HStack(alignment: .top, spacing: 0) {
            // Left accent bar — 3px, full row height
            Rectangle()
                .fill(entry.state.accentColor.opacity(0.4))
                .frame(width: 3)

            // Glyph — fixed 40pt column, vertically centred to first text line
            Text(entry.glyph)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(entry.state.accentColor)
                .frame(width: 40, alignment: .center)
                .padding(.top, 11)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.label)
                    .font(FieldType.chamberLabel)
                    .foregroundStyle(FieldPalette.textPrimary)
                Text(entry.detail)
                    .font(FieldType.frequency)
                    .foregroundStyle(entry.state.accentColor.opacity(0.9))
                if let sub = entry.subDetail {
                    Text(sub)
                        .font(FieldType.frequency)
                        .foregroundStyle(FieldPalette.textMuted)
                }
            }
            .padding(.vertical, 11)
            .padding(.trailing, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(entry.state.backgroundColor)
    }

    // MARK: - Footer

    private var footer: some View {
        Text("PROMOTED = receipt-backed  ·  HOLD = must not be claimed")
            .font(FieldType.frequency)
            .foregroundStyle(FieldPalette.textDim)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    CockpitAlphaView()
        .frame(width: 600, height: 520)
}

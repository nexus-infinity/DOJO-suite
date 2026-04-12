import SwiftUI
import DOJOUI

struct ConversationHeader: View {
    @ObservedObject var health: ChamberHealthMonitor

    var body: some View {
        HStack(spacing: 12) {
            Text("◼︎")
                .font(.system(size: 18))
                .foregroundStyle(Chamber.dojo.color)
                .shadow(color: Chamber.dojo.glowColor, radius: 8)
            VStack(alignment: .leading, spacing: 1) {
                Text("DOJO")
                    .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                    .foregroundStyle(FieldPalette.textPrimary)
                Text("741 Hz · Manifestation")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(FieldPalette.textMuted)
            }
            Spacer()
            HStack(spacing: 5) {
                Circle()
                    .fill(health.status[.dojo] == .alive ? Chamber.dojo.color : Color.red.opacity(0.5))
                    .frame(width: 6, height: 6)
                    .shadow(color: health.status[.dojo] == .alive ? Chamber.dojo.glowColor : .clear, radius: 4)
                Text(health.status[.dojo] == .alive ? "LIVE" : "OFFLINE")
                    .font(.system(.caption2, design: .monospaced, weight: .medium))
                    .foregroundStyle(health.status[.dojo] == .alive ? Chamber.dojo.color : FieldPalette.textDim)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(FieldPalette.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Chamber.dojo.color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(FieldPalette.surface.opacity(0.8))
        .overlay(alignment: .bottom) {
            Rectangle().fill(FieldPalette.border).frame(height: 1)
        }
    }
}

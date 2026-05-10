import SwiftUI
import FieldKit

struct PacketTimelineView: View {
    @EnvironmentObject private var store: PacketStore
    @Binding var selectedID: UUID?

    var body: some View {
        List(store.packets, selection: $selectedID) { packet in
            PacketTimelineRow(packet: packet)
                .listRowBackground(
                    selectedID == packet.id
                        ? Color(hex: "#1E1B2E")
                        : Color(hex: "#111113")
                )
                .listRowSeparatorTint(Color(hex: "#1F1F23"))
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .background(Color(hex: "#0D0D0F"))
        .navigationTitle("Packets (\(store.packets.count))")
    }
}

struct PacketTimelineRow: View {
    let packet: Packet

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Circle()
                .fill(stateColor)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 3) {
                Text(packet.textNotes.isEmpty ? "(no notes)" : packet.textNotes)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color(hex: "#E2E8F0"))
                    .lineLimit(2)
                Text(Self.timeFormatter.string(from: packet.createdAt))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Color(hex: "#4B5563"))
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var stateColor: Color {
        switch packet.state {
        case .validated:               return Color(hex: "#22C55E")
        case .hold:                    return Color(hex: "#F43F5E")
        case .queued, .retrying:       return Color(hex: "#F59E0B")
        case .uploading:               return Color(hex: "#3B82F6")
        case .sent, .acknowledged:     return Color(hex: "#14B8A6")
        case .failed:                  return Color(hex: "#EF4444")
        case .draft, .expired:         return Color(hex: "#6B7280")
        }
    }
}

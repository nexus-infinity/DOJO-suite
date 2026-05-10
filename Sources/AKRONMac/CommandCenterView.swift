import SwiftUI
import FieldKit

struct CommandCenterView: View {
    @EnvironmentObject private var store: PacketStore
    @State private var selectedID: UUID?

    private var selected: Packet? {
        store.packets.first { $0.id == selectedID }
    }

    var body: some View {
        NavigationSplitView {
            PacketTimelineView(selectedID: $selectedID)
                .navigationSplitViewColumnWidth(min: 260, ideal: 300)
        } detail: {
            if let packet = selected {
                PacketDetailView(packet: packet)
            } else {
                emptyDetail
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    Task { await store.refresh() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }
        .task { await store.refresh() }
    }

    private var emptyDetail: some View {
        VStack(spacing: 12) {
            Text("◼︎")
                .font(.system(size: 48))
                .foregroundStyle(Color(hex: "#2D2D30"))
            Text("Select a packet")
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(Color(hex: "#4B5563"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#0A0A0C"))
    }
}

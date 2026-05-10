import SwiftUI
import FieldKit

struct PacketListView: View {
    @EnvironmentObject private var queue: PacketQueue
    @State private var showCapture = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0A0A0C").ignoresSafeArea()

                if queue.packets.isEmpty {
                    VStack(spacing: 12) {
                        Text("◼︎")
                            .font(.system(size: 40))
                            .foregroundStyle(Color(hex: "#2D2D30"))
                        Text("No packets yet")
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(Color(hex: "#4B5563"))
                        Text("Tap + to capture")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(Color(hex: "#374151"))
                    }
                } else {
                    List {
                        ForEach(queue.packets) { packet in
                            PacketRowView(packet: packet)
                                .listRowBackground(Color(hex: "#111113"))
                                .listRowSeparatorTint(Color(hex: "#1F1F23"))
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("◼︎ FIELD")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCapture = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color(hex: "#7C3AED"))
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showCapture) {
                CaptureView()
                    .environmentObject(queue)
            }
        }
    }
}

struct PacketRowView: View {
    let packet: Packet

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(packet.textNotes.isEmpty ? "(no notes)" : packet.textNotes)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color(hex: "#E2E8F0"))
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Text(Self.dateFormatter.string(from: packet.createdAt))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color(hex: "#4B5563"))

                    if let receipt = packet.receipt {
                        Text("◼︎ \(receipt.receiptID.prefix(8))")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(Color(hex: "#4B5563"))
                    }
                }

                if let receipt = packet.receipt, !receipt.chamberTrace.isEmpty {
                    Text(receipt.chamberTrace.joined(separator: " → "))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Color(hex: "#374151"))
                }

                if let reasons = packet.receipt?.holdReasons, !reasons.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(reasons, id: \.self) { reason in
                            Text("⚠ \(reason)")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(Color(hex: "#F43F5E"))
                        }
                    }
                }
            }

            Spacer()
            PacketStateChip(state: packet.state)
        }
        .padding(.vertical, 8)
    }
}

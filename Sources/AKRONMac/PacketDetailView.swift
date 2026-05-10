import SwiftUI
import FieldKit

struct PacketDetailView: View {
    let packet: Packet

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                notesSection
                integritySection
                if let receipt = packet.receipt {
                    receiptSection(receipt)
                }
                if let receipt = packet.receipt, !receipt.chamberTrace.isEmpty {
                    traceSection(receipt.chamberTrace)
                }
                if let reasons = packet.receipt?.holdReasons, !reasons.isEmpty {
                    holdSection(reasons)
                }
            }
            .padding(24)
        }
        .background(Color(hex: "#0A0A0C"))
    }

    private var headerSection: some View {
        HStack(spacing: 12) {
            PacketStateChip(state: packet.state)
            Text(packet.id.uuidString.prefix(8).uppercased())
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Color(hex: "#4B5563"))
            Spacer()
            Text(packet.createdAt, style: .date)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Color(hex: "#4B5563"))
            Text(packet.createdAt, style: .time)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Color(hex: "#4B5563"))
        }
    }

    private var notesSection: some View {
        fieldBlock(label: "NOTES") {
            Text(packet.textNotes.isEmpty ? "(no notes)" : packet.textNotes)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color(hex: "#E2E8F0"))
        }
    }

    private var integritySection: some View {
        fieldBlock(label: "INTEGRITY") {
            VStack(alignment: .leading, spacing: 6) {
                hashRow("SHA-256", packet.integrityHash)
                if let prev = packet.previousPacketHash {
                    hashRow("PREV", prev)
                }
                hashRow("DEVICE", packet.deviceID)
            }
        }
    }

    private func receiptSection(_ receipt: PacketReceipt) -> some View {
        fieldBlock(label: "RECEIPT") {
            VStack(alignment: .leading, spacing: 6) {
                hashRow("ID", receipt.receiptID)
                hashRow("RESULT", receipt.validationResult)
                Text("Received \(receipt.receivedAt)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color(hex: "#6B7280"))
            }
        }
    }

    private func traceSection(_ trace: [String]) -> some View {
        fieldBlock(label: "CHAMBER TRACE") {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(trace.enumerated()), id: \.offset) { idx, node in
                    HStack(spacing: 8) {
                        Text("\(idx + 1)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(Color(hex: "#374151"))
                            .frame(width: 16, alignment: .trailing)
                        Text(node)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(Color(hex: "#A78BFA"))
                    }
                }
            }
        }
    }

    private func holdSection(_ reasons: [String]) -> some View {
        fieldBlock(label: "HOLD REASONS") {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(reasons, id: \.self) { reason in
                    HStack(spacing: 6) {
                        Text("⚠")
                            .font(.system(size: 11))
                        Text(reason)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(Color(hex: "#F43F5E"))
                    }
                }
            }
        }
    }

    private func fieldBlock<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color(hex: "#374151"))
                .kerning(1.2)
            content()
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "#111113"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color(hex: "#1F1F23"), lineWidth: 1)
                )
        }
    }

    private func hashRow(_ label: String, _ value: String) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(Color(hex: "#4B5563"))
                .frame(width: 56, alignment: .leading)
            Text(value)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(Color(hex: "#6B7280"))
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}

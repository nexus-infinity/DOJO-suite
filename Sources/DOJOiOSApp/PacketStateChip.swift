import SwiftUI
#if canImport(FieldKit)
import FieldKit
#endif
#if canImport(DOJOShared)
import DOJOShared
#endif

struct PacketStateChip: View {
    let state: PacketState

    var body: some View {
        Text(state.rawValue)
            .font(.system(size: 10, weight: .semibold, design: .monospaced))
            .foregroundStyle(chipColor)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(chipColor.opacity(0.15))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(chipColor.opacity(0.4), lineWidth: 1))
    }

    private var chipColor: Color {
        switch state {
        case .draft:        return Color(hex: "#6B7280")
        case .queued:       return Color(hex: "#F59E0B")
        case .uploading:    return Color(hex: "#3B82F6")
        case .sent:         return Color(hex: "#14B8A6")
        case .acknowledged: return Color(hex: "#14B8A6")
        case .validated:    return Color(hex: "#22C55E")
        case .hold:         return Color(hex: "#F43F5E")
        case .failed:       return Color(hex: "#EF4444")
        case .retrying:     return Color(hex: "#F59E0B")
        case .expired:      return Color(hex: "#4B5563")
        }
    }
}

extension Color {
    init(hex: String) {
        let h = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        let val = UInt64(h, radix: 16) ?? 0
        let r = Double((val >> 16) & 0xFF) / 255
        let g = Double((val >> 8) & 0xFF) / 255
        let b = Double(val & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

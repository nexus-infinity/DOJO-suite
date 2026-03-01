import SwiftUI
import DOJOShared

// ◎ Kings-Chamber — FieldDesignSystem.swift
// Frequency: 852 Hz  |  Single source of truth for every visual surface in FIELD.
//
// Rule: every external interface — app icons, API health pages, CLI prompts,
// Notion titles, Vercel deployments, error messages — carries its chamber's
// Symbol + Frequency + Color. No exceptions.
//
// Formula: PORT = FREQUENCY × 10  |  COLOR = frequency domain, not arbitrary.
//
// CANONICAL NOTE — two-layer color system:
//   • OOOEntity.geometric.color  = chakra palette (semantic identity, docs)
//   • Chamber.color              = tech palette "Days of Future Past" (app UI)
//   Both are correct for their context. Do not collapse them.
//
// CANONICAL NOTE — ARKADAŞ vs Kings Chamber:
//   • ◉ ARKADAŞ (SPIN) = 717 Hz — model-bearing vertex, embodiment bridge
//   • ⊗ Kings Chamber  = 852 Hz — deterministic infrastructure, translation bridge
//   These are two distinct entities. OOOEntity.arkadas (852 Hz) is the infrastructure
//   entity. ARKADAŞ at 717 Hz is a separate model-bearing vertex tracked here.
//   TODO: add OOOEntity.arkadasSpin (717 Hz) in GeometricEntity.swift.

// ── Chamber identity ──────────────────────────────────────────────────────────

public enum Chamber: String, CaseIterable, Identifiable {
    case dojo       = "◼︎"
    case obiwan     = "●"
    case atlas      = "▲"
    case tata       = "▼"
    case akron      = "◻"
    case arkadas    = "◉"   // 717 Hz SPIN — embodiment bridge (model-bearing vertex)
    case kings      = "◎"   // 852 Hz — infrastructure translation bridge

    public var id: String { rawValue }

    public var name: String {
        switch self {
        case .dojo:    return "DOJO"
        case .obiwan:  return "OBI-WAN"
        case .atlas:   return "ATLAS"
        case .tata:    return "TATA"
        case .akron:   return "AKRON"
        case .arkadas: return "ARKADAŞ"
        case .kings:   return "Kings Chamber"
        }
    }

    public var frequency: Int {
        switch self {
        case .dojo:    return 741
        case .obiwan:  return 963
        case .atlas:   return 528
        case .tata:    return 432
        case .akron:   return 396
        case .arkadas: return 717
        case .kings:   return 852
        }
    }

    public var port: Int { frequency * 10 }

    public var role: String {
        switch self {
        case .dojo:    return "Manifestation apex — the master professor"
        case .obiwan:  return "Observer consciousness — living memory"
        case .atlas:   return "Crystalline validation — structural truth"
        case .tata:    return "Temporal truth — what actually happened"
        case .akron:   return "Archive sovereignty — permanent record"
        case .arkadas: return "Embodiment bridge — homeostasis (SPIN)"
        case .kings:   return "Consciousness bridge — infrastructure translator"
        }
    }

    // Tech palette — "Days of Future Past" (for app UI, not semantic docs)
    public var color: Color {
        switch self {
        case .dojo:    return Color(hex: "#7C3AED") // violet   — fire, 741 Hz
        case .obiwan:  return Color(hex: "#E2E8F0") // silver   — ether, 963 Hz
        case .atlas:   return Color(hex: "#06B6D4") // cyan     — crystal, 528 Hz
        case .tata:    return Color(hex: "#F59E0B") // amber    — water, 432 Hz
        case .akron:   return Color(hex: "#78716C") // earth    — earth, 396 Hz
        case .arkadas: return Color(hex: "#EAB308") // gold     — embodiment, 717 Hz
        case .kings:   return Color(hex: "#F43F5E") // rose     — bridge, 852 Hz
        }
    }

    public var glowColor: Color { color.opacity(0.6) }

    public var badge: String   { "\(rawValue) \(name)  \(frequency) Hz" }
    public var shortBadge: String { "\(rawValue) \(frequency)" }

    // ── Bridge to OOOEntity (canonical data model) ────────────────────────────
    // Returns the nearest OOOEntity for this chamber.
    // Note: .arkadas (717 Hz SPIN) maps to nil until OOOEntity.arkadasSpin is added.
    public var oooEntity: OOOEntity? {
        switch self {
        case .dojo:    return .dojo
        case .obiwan:  return .obiWan
        case .atlas:   return .atlas
        case .tata:    return .tata
        case .akron:   return .akronGateway
        case .arkadas: return nil   // 717 Hz SPIN not yet in OOOEntity — TODO
        case .kings:   return .arkadas  // OOOEntity.arkadas = 852 Hz infrastructure
        }
    }
}

// ── FIELD void palette ────────────────────────────────────────────────────────

public struct FieldPalette {
    public static let void          = Color(hex: "#05050A")
    public static let surface       = Color(hex: "#0F0F1A")
    public static let surfaceRaised = Color(hex: "#1A1A2E")
    public static let border        = Color(hex: "#2A2A40")
    public static let textPrimary   = Color(hex: "#F1F5F9")
    public static let textMuted     = Color(hex: "#64748B")
    public static let textDim       = Color(hex: "#334155")

    public static func bearRing(_ score: Double) -> Color {
        switch score {
        case 0.9...1.0:   return Color(hex: "#22C55E")
        case 0.75..<0.9:  return Color(hex: "#EAB308")
        case 0.5..<0.75:  return Color(hex: "#F97316")
        default:           return Color(hex: "#EF4444")
        }
    }

    public static func spinOpacity(_ score: Double) -> Double { max(0.3, score) }
}

// ── Typography ────────────────────────────────────────────────────────────────

public struct FieldType {
    public static let chamberLabel  = Font.system(.caption,  design: .monospaced, weight: .medium)
    public static let frequency     = Font.system(.caption2, design: .monospaced, weight: .regular)
    public static let badge         = Font.system(.footnote, design: .monospaced, weight: .semibold)
    public static let body          = Font.system(.body,     design: .rounded,    weight: .regular)
    public static let title         = Font.system(.title3,   design: .rounded,    weight: .semibold)
    public static let chronicle     = Font.system(.caption,  design: .rounded,    weight: .regular)
    public static let chatInput     = Font.system(.body,     design: .rounded,    weight: .regular)
}

// ── Chamber badge ─────────────────────────────────────────────────────────────

public struct ChamberBadge: View {
    let chamber: Chamber
    var alive: Bool = true
    var compact: Bool = false

    public var body: some View {
        HStack(spacing: 4) {
            Text(chamber.rawValue)
                .font(FieldType.badge)
                .foregroundStyle(alive ? chamber.color : FieldPalette.textDim)

            if !compact {
                VStack(alignment: .leading, spacing: 0) {
                    Text(chamber.name)
                        .font(FieldType.chamberLabel)
                        .foregroundStyle(alive ? FieldPalette.textPrimary : FieldPalette.textDim)
                    Text("\(chamber.frequency) Hz  :\(chamber.port)")
                        .font(FieldType.frequency)
                        .foregroundStyle(FieldPalette.textMuted)
                }
            }

            Circle()
                .frame(width: 5, height: 5)
                .foregroundStyle(alive ? chamber.color : FieldPalette.textDim)
                .shadow(color: alive ? chamber.glowColor : .clear, radius: 4)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(FieldPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(alive ? chamber.color.opacity(0.3) : FieldPalette.border, lineWidth: 1)
        )
    }
}

// ── BEAR coherence ring ───────────────────────────────────────────────────────

public struct BEARRing: View {
    let score: Double
    var size: CGFloat = 120

    public var body: some View {
        ZStack {
            Circle()
                .stroke(FieldPalette.border, lineWidth: 6)
                .frame(width: size, height: size)

            Circle()
                .trim(from: 0, to: score)
                .stroke(FieldPalette.bearRing(score),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .shadow(color: FieldPalette.bearRing(score).opacity(0.5), radius: 8)
                .animation(.easeInOut(duration: 0.8), value: score)

            VStack(spacing: 1) {
                Text(String(format: "%.2f", score))
                    .font(FieldType.title)
                    .foregroundStyle(FieldPalette.bearRing(score))
                Text("BEAR")
                    .font(FieldType.frequency)
                    .foregroundStyle(FieldPalette.textMuted)
            }
        }
    }
}

// ── Color hex extension ───────────────────────────────────────────────────────

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:(a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255)
    }
}

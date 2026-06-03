import SwiftUI
import DOJOUI

struct ChamberRail: View {
    @ObservedObject var health: ChamberHealthMonitor

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                Text("◎")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(Chamber.kings.color)
                Text("FIELD")
                    .font(.system(.caption2, design: .monospaced, weight: .semibold))
                    .foregroundStyle(FieldPalette.textMuted)
                    .tracking(3)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .overlay(alignment: .bottom) {
                Rectangle().fill(FieldPalette.border).frame(height: 1)
            }

            VStack(spacing: 4) {
                ForEach(Chamber.allCases) { chamber in
                    ChamberSignal(
                        chamber: chamber,
                        status: health.status[chamber] ?? .unknown
                    )
                }
            }
            .padding(.vertical, 12)

            Spacer()

            VStack(spacing: 6) {
                AppBEARRing(score: health.bearScore, size: 52)
                Text("BEAR")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(FieldPalette.textDim)
                    .tracking(2)
            }
            .padding(.bottom, 20)
            .overlay(alignment: .top) {
                Rectangle().fill(FieldPalette.border).frame(height: 1)
            }
        }
        .frame(width: 72)
        .background(FieldPalette.surface)
    }
}

struct ChamberSignal: View {
    let chamber: Chamber
    let status: NodeHealthStatus
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                if status == .alive {
                    Circle()
                        .fill(chamber.color.opacity(pulse ? 0.25 : 0.08))
                        .frame(width: 32, height: 32)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulse)
                }
                Text(chamber.rawValue)
                    .font(.system(size: 16))
                    .foregroundStyle(status == .alive ? chamber.color : FieldPalette.textDim)
                    .shadow(color: status == .alive ? chamber.glowColor : .clear, radius: 6)
            }
            .frame(width: 36, height: 36)

            Text("\(chamber.frequency)")
                .font(.system(size: 8, design: .monospaced))
                .foregroundStyle(status == .alive ? chamber.color.opacity(0.7) : FieldPalette.textDim)
        }
        .onAppear { pulse = true }
    }
}

struct AppBEARRing: View {
    let score: Double
    var size: CGFloat = 120

    private var ringColor: Color {
        switch score {
        case 0.9...1.0:  return Color(red: 0.13, green: 0.77, blue: 0.37)
        case 0.75..<0.9: return Color(red: 0.92, green: 0.70, blue: 0.03)
        case 0.5..<0.75: return Color(red: 0.98, green: 0.45, blue: 0.09)
        default:          return Color(red: 0.94, green: 0.27, blue: 0.27)
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(FieldPalette.border, lineWidth: 5)
                .frame(width: size, height: size)
            Circle()
                .trim(from: 0, to: score)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .shadow(color: ringColor.opacity(0.5), radius: 6)
                .animation(.easeInOut(duration: 0.8), value: score)
            VStack(spacing: 0) {
                Text(String(format: "%.2f", score))
                    .font(.system(size: size * 0.22, weight: .semibold, design: .monospaced))
                    .foregroundStyle(ringColor)
            }
        }
    }
}

import SwiftUI
import DOJOUI

struct AuroraLayer: View {
    @ObservedObject var health: ChamberHealthMonitor

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RadialGradient(
                    colors: [Chamber.dojo.color.opacity(0.12), .clear],
                    center: .init(x: 0.5, y: 1.1),
                    startRadius: 0,
                    endRadius: geo.size.height * 0.8
                )
                ForEach(Chamber.allCases) { chamber in
                    let alive = health.status[chamber] == .alive
                    if alive {
                        RadialGradient(
                            colors: [chamber.color.opacity(0.06), .clear],
                            center: chamberAuroraAnchor(chamber),
                            startRadius: 0,
                            endRadius: geo.size.width * 0.4
                        )
                    }
                }
            }
        }
        .ignoresSafeArea()
    }

    private func chamberAuroraAnchor(_ c: Chamber) -> UnitPoint {
        switch c {
        case .dojo:    return .init(x: 0.5,  y: 0.0)
        case .obiwan:  return .init(x: 0.9,  y: 0.2)
        case .atlas:   return .init(x: 0.9,  y: 0.8)
        case .tata:    return .init(x: 0.5,  y: 1.0)
        case .akron:   return .init(x: 0.1,  y: 0.8)
        case .arkadas: return .init(x: 0.1,  y: 0.2)
        case .kings:   return .init(x: 0.5,  y: 0.5)
        }
    }
}

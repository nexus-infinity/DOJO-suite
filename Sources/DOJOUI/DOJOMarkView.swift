import SwiftUI

// MARK: - DOJO Mark
//
// Spinning-top mark: ◼︎ DOJO (741 Hz) outer triangle containing ⬢ Arkadaş (852 Hz)
// hexagon, wrapped in ◻ Akron Gateway (396 Hz) ring.
//
// Color palette: Notion canonical "Sacred Color Palette" (visual production assets).
// Distinct from FieldPalette tech tokens — do not mix contexts.
//
// Arkadaş: ş = LATIN SMALL LETTER S WITH CEDILLA (U+015F) — Turkish "friend/companion"

public struct DOJOMarkView: View {
    public var size: CGFloat = 120

    public init(size: CGFloat = 120) {
        self.size = size
    }

    public var body: some View {
        Canvas { ctx, canvasSize in
            let s = canvasSize.width
            let cx = s / 2
            let cy = s / 2

            // Scale factor relative to the 1024px reference design
            let scale = s / 1024

            let ringR   = 420 * scale
            let triR    = 330 * scale
            let hexR    = 115 * scale
            let dotR    =  13 * scale
            let halfPi  = CGFloat.pi / 2
            let twoThirds = CGFloat.pi * 2 / 3

            // ── Akron ring: #00D9FF ───────────────────────────────────────────
            let ringRect = CGRect(x: cx - ringR, y: cy - ringR,
                                  width: ringR * 2, height: ringR * 2)
            let ringPath = Path(ellipseIn: ringRect)

            ctx.drawLayer { l in
                l.addFilter(.blur(radius: 8 * scale))
                l.stroke(ringPath,
                         with: .color(Color(hex: "#00D9FF").opacity(0.45)),
                         lineWidth: 14 * scale)
            }
            ctx.stroke(ringPath,
                       with: .color(Color(hex: "#00D9FF")),
                       lineWidth: 5 * scale)

            // ── DOJO triangle ▲: #9B59B6 ─────────────────────────────────────
            let ptTop  = CGPoint(x: cx + triR * cos(halfPi),           y: cy - triR * sin(halfPi))
            let ptBotL = CGPoint(x: cx + triR * cos(halfPi + twoThirds), y: cy - triR * sin(halfPi + twoThirds))
            let ptBotR = CGPoint(x: cx + triR * cos(halfPi - twoThirds), y: cy - triR * sin(halfPi - twoThirds))

            var triPath = Path()
            triPath.move(to: ptTop)
            triPath.addLine(to: ptBotL)
            triPath.addLine(to: ptBotR)
            triPath.closeSubpath()

            ctx.fill(triPath, with: .color(Color(hex: "#9B59B6").opacity(0.07)))
            ctx.drawLayer { l in
                l.addFilter(.blur(radius: 10 * scale))
                l.stroke(triPath,
                         with: .color(Color(hex: "#BB8FCE").opacity(0.4)),
                         lineWidth: 12 * scale)
            }
            ctx.stroke(triPath,
                       with: .color(Color(hex: "#9B59B6")),
                       lineWidth: 4 * scale)

            // ── Arkadaş hexagon ⬢: #8B5CF6 ───────────────────────────────────
            var hexPath = Path()
            for i in 0..<6 {
                // SwiftUI Canvas: y-down, so negate sin for upward orientation
                let angle = halfPi + CGFloat(i) * (CGFloat.pi / 3)
                let pt = CGPoint(x: cx + hexR * cos(angle), y: cy - hexR * sin(angle))
                if i == 0 { hexPath.move(to: pt) } else { hexPath.addLine(to: pt) }
            }
            hexPath.closeSubpath()

            ctx.fill(hexPath, with: .color(Color(hex: "#6B46C1").opacity(0.14)))
            ctx.drawLayer { l in
                l.addFilter(.blur(radius: 8 * scale))
                l.stroke(hexPath,
                         with: .color(Color(hex: "#8B5CF6").opacity(0.5)),
                         lineWidth: 8 * scale)
            }
            ctx.stroke(hexPath,
                       with: .color(Color(hex: "#8B5CF6")),
                       lineWidth: 3 * scale)

            // ── Apex dot: DOJO ◼︎ glow ─────────────────────────────────────────
            let dotRect = CGRect(x: cx - dotR, y: cy - dotR, width: dotR * 2, height: dotR * 2)
            let dotPath = Path(ellipseIn: dotRect)
            ctx.drawLayer { l in
                l.addFilter(.blur(radius: 12 * scale))
                l.fill(dotPath, with: .color(Color(hex: "#BB8FCE").opacity(0.9)))
            }
            ctx.fill(dotPath, with: .color(Color(hex: "#BB8FCE")))
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        Color(hex: "#0A0E27")
        DOJOMarkView(size: 320)
    }
    .frame(width: 400, height: 400)
}

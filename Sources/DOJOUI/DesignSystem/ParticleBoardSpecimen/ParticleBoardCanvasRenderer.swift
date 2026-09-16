import SwiftUI
import DOJOShared

public struct ParticleBoardSpecimenFrame: View {
    public let state: ParticleBoardVisualState
    public let envelope: DraftManifestationEnvelope?
    public let particles: [VisualParticle]
    public let reduceMotion: Bool
    public let debugOverlay: Bool

    public init(
        state: ParticleBoardVisualState,
        envelope: DraftManifestationEnvelope?,
        particles: [VisualParticle],
        reduceMotion: Bool = false,
        debugOverlay: Bool = false
    ) {
        self.state = state
        self.envelope = envelope
        self.particles = particles
        self.reduceMotion = reduceMotion
        self.debugOverlay = debugOverlay
    }

    public var body: some View {
        let frame = AikidoOpticsProjection.frame(state: state, particles: particles, reduceMotion: reduceMotion)
        ZStack {
            ParticleBoardCanvas(frame: frame)
            if ParticleBoardStateMachine.canRevealContent(state: state, envelope: envelope) {
                artifactCard(frame: frame)
            }
            if state == .held || state == .unknown {
                holdUnknownCard
            }
            VStack {
                HStack {
                    proofLabel
                    Spacer()
                    stateBadge
                }
                Spacer()
                if debugOverlay {
                    debugPanel(frame: frame)
                }
            }
            .padding(18)
        }
        .frame(minWidth: 860, minHeight: 560)
        .background(Color(hex: "#0A1A1A"))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilitySummary)
    }

    private var proofLabel: some View {
        Text("FIXTURE / DEVELOPMENT PROOF - NOT LIVE LOCATION")
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .tracking(0.8)
            .foregroundStyle(Color(hex: "#FAFAFA"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: "#061313").opacity(0.82))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(hex: "#1A7A7A").opacity(0.38), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var stateBadge: some View {
        Text(state.rawValue.uppercased())
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundStyle(state == .held ? Color(hex: "#FFD700") : Color(hex: "#00D9D9"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: "#061313").opacity(0.82))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(hex: "#6B4D9B").opacity(0.50), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func artifactCard(frame: AikidoOpticsFrame) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("DRAFT ARTIFACT")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(hex: "#00D9D9"))
                    Text(envelope?.candidateID ?? "Unknown candidate")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color(hex: "#A7F3F3"))
                }
                Spacer()
                Text(envelope?.requestedFidelity.rawValue.uppercased() ?? "UNKNOWN")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(hex: "#FFD700"))
            }

            Divider().overlay(Color(hex: "#1A7A7A").opacity(0.4))

            VStack(alignment: .leading, spacing: 8) {
                artifactRow("Source", envelope?.sourceLabel ?? "Unknown")
                artifactRow("Evidence", envelope?.evidenceAnchors.first?.anchorID ?? "Unknown.Source")
                artifactRow("Authority", envelope?.projectionAuthorityStatus.decision.rawValue ?? "UNKNOWN")
                artifactRow("Correction", envelope?.correctionRoute.destination ?? "Unknown")
                artifactRow("Boundary", "Preview only - no save/send/publish/device operation")
            }
        }
        .padding(22)
        .frame(width: 520)
        .background(Color(hex: "#FAFAFA").opacity(0.96))
        .foregroundStyle(Color(hex: "#0A1A1A"))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#00D9D9").opacity(0.72), lineWidth: 1.2))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .opacity(Double(frame.artifactOpacity))
        .blur(radius: CGFloat(frame.artifactBlur))
        .accessibilityLabel("Readable fixture draft artifact. No external action enabled.")
    }

    private var holdUnknownCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(state == .held ? "HOLD" : "UNKNOWN")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(state == .held ? Color(hex: "#FFD700") : Color(hex: "#A7F3F3"))
            Text(state == .held ? "Presentation authority is held. Artifact content is not revealed." : "Required candidate, source, correction, or surface grounding is unknown.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#FAFAFA"))
            Text("No delivery, consent, save, send, publish, or app control is inferred.")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color(hex: "#8DDDE8"))
        }
        .padding(18)
        .frame(width: 420, alignment: .leading)
        .background(Color(hex: "#061313").opacity(0.92))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#6B4D9B").opacity(0.55), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func artifactRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(Color(hex: "#1A7A7A"))
                .frame(width: 74, alignment: .leading)
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#0A1A1A"))
                .lineLimit(3)
            Spacer()
        }
    }

    private func debugPanel(frame: AikidoOpticsFrame) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("state \(state.rawValue)")
            Text("particles \(frame.particles.count)")
            Text(String(format: "focus %.2f", frame.opticalFocus))
            Text(String(format: "convergence %.2f", frame.convergence))
            Text("candidate \(envelope?.candidateID ?? "none")")
            Text("authority \(envelope?.projectionAuthorityStatus.decision.rawValue ?? "UNKNOWN")")
        }
        .font(.system(size: 10, weight: .semibold, design: .monospaced))
        .foregroundStyle(Color(hex: "#A7F3F3"))
        .padding(10)
        .background(Color(hex: "#061313").opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var accessibilitySummary: String {
        "ParticleBoard Aikido Optics specimen, state \(state.rawValue), fixture only, no live location, no external action."
    }
}

public struct ParticleBoardCanvas: View {
    public let frame: AikidoOpticsFrame

    public init(frame: AikidoOpticsFrame) {
        self.frame = frame
    }

    public var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(hex: "#0A1A1A")))
            drawStructuralTrace(in: context, size: size)
            for particle in frame.particles {
                draw(particle, in: context, size: size)
            }
        }
    }

    private func drawStructuralTrace(in context: GraphicsContext, size: CGSize) {
        let rect = CGRect(x: size.width * 0.18, y: size.height * 0.18, width: size.width * 0.64, height: size.height * 0.64)
        context.stroke(Path(ellipseIn: rect), with: .color(Color(hex: "#1A7A7A").opacity(0.08)), lineWidth: 1)
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        context.stroke(path, with: .color(Color(hex: "#6B4D9B").opacity(Double(0.24 + frame.opticalFocus * 0.28))), lineWidth: 1)
    }

    private func draw(_ particle: VisualParticle, in context: GraphicsContext, size: CGSize) {
        let point = CGPoint(
            x: size.width * CGFloat(0.5 + particle.position.x * 0.72),
            y: size.height * CGFloat(0.5 + particle.position.y * 0.72)
        )
        let radius = CGFloat(1.6 + particle.lockProgress * 2.6 + particle.depth)
        let color = Color(
            red: Double(particle.colour.x),
            green: Double(particle.colour.y),
            blue: Double(particle.colour.z)
        )
        let alpha = Double(min(1, max(0, particle.opacity)))
        let rect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        let path: Path
        switch particle.primitive {
        case .circle:
            path = Path(ellipseIn: rect)
        case .triangle:
            var p = Path()
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.closeSubpath()
            path = p
        case .square:
            path = Path(rect)
        case .diamond:
            var p = Path()
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            p.closeSubpath()
            path = p
        case .hexagon:
            path = hexagon(in: rect)
        }
        context.fill(path, with: .color(color.opacity(alpha)))
    }

    private func hexagon(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        for index in 0..<6 {
            let angle = CGFloat(index) / 6.0 * .pi * 2 + .pi / 6
            let point = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

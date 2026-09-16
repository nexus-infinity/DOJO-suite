import SwiftUI
import AppKit
import DOJOUI

#if os(macOS)

// MARK: - Main App

@available(macOS 14.0, *)
@main
struct DOJOApp: App {
    var body: some Scene {
        // The application is DOJO Today. Other scenes are labs / linked depth.
        WindowGroup("DOJO Today") {
            DOJOTodaySurfaceView()
        }
        .defaultSize(width: 1180, height: 820)
        .commands {
            LabsWindowCommands()
        }

        Window("Today / Capture specimen", id: "today-capture") {
            TodayCaptureEntranceView()
        }
        .defaultSize(width: 980, height: 720)

        Window("Apple Surface Matrix", id: "apple-surface-matrix") {
            AppleSurfaceMatrixCandidateView()
        }
        .defaultSize(width: 1180, height: 820)

        Window("FIELD Editor Matrix", id: "field-editor-matrix") {
            EditorMatrixDashboardView()
        }
        .defaultSize(width: 1180, height: 820)

        Window("G6 Hardware Channel", id: "g6-hardware-channel") {
            DOJOAudioCaptureView()
        }
        .defaultSize(width: 520, height: 650)

        Window("Cockpit Alpha", id: "cockpit-alpha") {
            CockpitAlphaView()
        }
        .defaultSize(width: 600, height: 520)
    }
}

@available(macOS 14.0, *)
private struct LabsWindowCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandMenu("Labs") {
            Button("Today / Capture specimen") {
                openWindow(id: "today-capture")
            }
            Button("Apple Surface Matrix") {
                openWindow(id: "apple-surface-matrix")
            }
            Button("FIELD Editor Matrix") {
                openWindow(id: "field-editor-matrix")
            }
            Button("G6 Hardware Channel") {
                openWindow(id: "g6-hardware-channel")
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])
            Button("Cockpit Alpha") {
                openWindow(id: "cockpit-alpha")
            }
        }
    }
}

private struct AppleSurfaceMatrixCandidateView: View {
    private let surfaces = AppleSurface.allCases

    var body: some View {
        ZStack {
            TodayParticleAtmosphere()

            VStack(alignment: .leading, spacing: 22) {
                header
                tileGrid
                authorityFooter
            }
            .padding(30)
        }
        .frame(minWidth: 1040, minHeight: 720)
        .background(Color(hex: "#041417"))
    }

    private var header: some View {
        HStack(alignment: .bottom, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("APPLE REQUIRED SURFACE MATRIX v0")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .tracking(1.2)
                    .foregroundStyle(Color(hex: "#8DDDE8"))

                Text("DOJO Suite Candidate Card")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .foregroundStyle(FieldPalette.textPrimary)

                Text("Technology carries the thread so the human can remain in the experience.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#BDECF2"))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text("STATIC SPECIMEN")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1.1)
                    .foregroundStyle(Chamber.dojo.color)

                Text("No runtime claim")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(FieldPalette.textMuted)
            }
        }
        .padding(20)
        .background(Color(hex: "#06171C").opacity(0.82))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#17404A"), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var tileGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(minimum: 300), spacing: 14),
                GridItem(.flexible(minimum: 300), spacing: 14),
                GridItem(.flexible(minimum: 300), spacing: 14)
            ],
            alignment: .leading,
            spacing: 14
        ) {
            ForEach(surfaces) { surface in
                SurfaceTile(surface: surface)
            }
        }
    }

    private var authorityFooter: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: "lock.shield")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Chamber.atlas.color)

            Text("Authority ceiling: visual embodiment proof only. Apple surfaces are expressions of the system, not the FIELD / DOJO runtime itself.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(FieldPalette.textPrimary)

            Spacer()

            Text("HOLD")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(1.4)
                .foregroundStyle(Color(hex: "#A78BFA"))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(hex: "#251847").opacity(0.68))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(16)
        .background(Color(hex: "#031014").opacity(0.78))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#17404A"), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct SurfaceTile: View {
    let surface: AppleSurface

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: surface.systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(surface.accent)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(surface.name)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(FieldPalette.textPrimary)

                    Text(surface.role)
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(surface.accent)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Text("HOLD")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(1.1)
                    .foregroundStyle(Color(hex: "#A78BFA"))
            }

            Divider()
                .overlay(Color(hex: "#17404A"))

            surfaceRow("Human situation", surface.situation)
            surfaceRow("Proof required", surface.proof)
            surfaceRow("Authority ceiling", surface.ceiling)
        }
        .padding(16)
        .frame(minHeight: 236, alignment: .topLeading)
        .background(Color(hex: "#06171C").opacity(0.88))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(surface.accent.opacity(0.45), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func surfaceRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .tracking(0.9)
                .foregroundStyle(FieldPalette.textMuted)

            Text(value)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(FieldPalette.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private enum AppleSurface: String, CaseIterable, Identifiable {
    case macOS
    case iPhone
    case iPad
    case watch
    case carPlay
    case appleTV

    var id: String { rawValue }

    var name: String {
        switch self {
        case .macOS: return "macOS"
        case .iPhone: return "iPhone / iOS"
        case .iPad: return "iPadOS"
        case .watch: return "watchOS"
        case .carPlay: return "CarPlay"
        case .appleTV: return "Apple TV / tvOS"
        }
    }

    var role: String {
        switch self {
        case .macOS: return "full command / review surface"
        case .iPhone: return "mobile capture vessel"
        case .iPad: return "portable creation / annotation"
        case .watch: return "quick cue / haptic / body-state signal"
        case .carPlay: return "vehicle cockpit attention surface"
        case .appleTV: return "room-scale shared display"
        }
    }

    var situation: String {
        switch self {
        case .macOS: return "At the desk, comparing state, language, receipts, and next action."
        case .iPhone: return "In motion, capturing a thought before it falls out of context."
        case .iPad: return "Portable sketch, review, markup, and slower creation work."
        case .watch: return "On the wrist, receiving a brief cue without entering configuration."
        case .carPlay: return "In the car, preserving attention with glanceable status only."
        case .appleTV: return "In the room, sharing a calm visible state with others present."
        }
    }

    var proof: String {
        switch self {
        case .macOS: return "One visible review card with all six ceilings readable."
        case .iPhone: return "Capture surface that stores locally until explicit choice."
        case .iPad: return "Annotation surface that separates draft from authority."
        case .watch: return "Cue surface with no medical or decision authority claim."
        case .carPlay: return "Attention-safe display only; no vehicle control."
        case .appleTV: return "Shared display specimen; no PULSE or room infrastructure claim."
        }
    }

    var ceiling: String {
        switch self {
        case .macOS: return "May review and approve visual language; does not prove runtime."
        case .iPhone: return "May capture locally; does not prove portal round-trip."
        case .iPad: return "May create and annotate; does not promote Suite canon."
        case .watch: return "May cue and reflect; does not infer health authority."
        case .carPlay: return "May show attention state; does not operate the vehicle."
        case .appleTV: return "May display shared context; does not prove live system presence."
        }
    }

    var systemImage: String {
        switch self {
        case .macOS: return "desktopcomputer"
        case .iPhone: return "iphone"
        case .iPad: return "ipad"
        case .watch: return "applewatch"
        case .carPlay: return "car"
        case .appleTV: return "tv"
        }
    }

    var accent: Color {
        switch self {
        case .macOS: return Chamber.atlas.color
        case .iPhone: return Color(hex: "#60A5FA")
        case .iPad: return Chamber.dojo.color
        case .watch: return Color(hex: "#A78BFA")
        case .carPlay: return Color(hex: "#22D3EE")
        case .appleTV: return Color(hex: "#C4B5FD")
        }
    }
}

private struct TodayCaptureEntranceView: View {
    @Environment(\.openWindow) private var openWindow
    @State private var selectedAction: EntranceAction?
    @State private var showsSystemDetails = false

    private let statusItems = [
        "Capture ready",
        "One item awaiting your decision",
        "System details"
    ]

    var body: some View {
        ZStack {
            TodayParticleAtmosphere()

            HStack(spacing: 0) {
                mainSurface
                statusEdge
            }
        }
        .frame(minWidth: 900, minHeight: 640)
        .background(Color(hex: "#041417"))
    }

    private var mainSurface: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 54)

            VStack(alignment: .leading, spacing: 30) {
                greeting
                actionGrid
                contextStrip
            }
            .frame(maxWidth: 660, alignment: .leading)

            Spacer(minLength: 42)
        }
        .padding(.leading, 62)
        .padding(.trailing, 38)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Good afternoon.")
                .font(.system(size: 42, weight: .semibold, design: .rounded))
                .foregroundStyle(FieldPalette.textPrimary)

            Text("What would you like to do?")
                .font(.system(size: 28, weight: .regular, design: .rounded))
                .foregroundStyle(Color(hex: "#BDECF2"))
        }
    }

    private var actionGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(minimum: 220), spacing: 12),
                GridItem(.flexible(minimum: 220), spacing: 12)
            ],
            alignment: .leading,
            spacing: 12
        ) {
            ForEach(EntranceAction.allCases) { action in
                Button {
                    selectedAction = action
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: action.systemImage)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(action.accent)
                            .frame(width: 22)

                        Text(action.title)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(FieldPalette.textPrimary)
                            .lineLimit(2)

                        Spacer(minLength: 8)
                    }
                    .padding(.horizontal, 16)
                    .frame(minHeight: 58)
                    .background(action == selectedAction ? Color(hex: "#102A36") : Color(hex: "#071D22").opacity(0.86))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(action == selectedAction ? action.accent.opacity(0.82) : Color(hex: "#17404A"), lineWidth: 1)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var contextStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            contextRow(label: "Current mode", value: "Copilot in the Field", color: Chamber.dojo.color)
            contextRow(label: "Privacy", value: "Local until you choose", color: Chamber.atlas.color)
            contextRow(label: "Last useful thread", value: "Unknown / placeholder", color: FieldPalette.textMuted)

            DisclosureGroup(isExpanded: $showsSystemDetails) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Static entrance specimen only.")
                    Text("No runtime activation, polling, vehicle surfaces, Suite canon promotion, or diagnostic matrices are changed here.")
                }
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(FieldPalette.textMuted)
                .padding(.top, 8)
            } label: {
                Text("System details")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: "#8DDDE8"))
            }
            .tint(Color(hex: "#8DDDE8"))
        }
        .padding(16)
        .background(Color(hex: "#06171C").opacity(0.82))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#17404A"), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func contextRow(label: String, value: String, color: Color) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("\(label):")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(FieldPalette.textMuted)
                .frame(width: 128, alignment: .leading)

            Text(value)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(color)

            Spacer(minLength: 0)
        }
    }

    private var statusEdge: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 36)

            VStack(alignment: .leading, spacing: 18) {
                Text("TODAY")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1.4)
                    .foregroundStyle(Color(hex: "#8DDDE8"))

                ForEach(statusItems, id: \.self) { item in
                    statusItem(item)
                }

                Button {
                    openWindow(id: "field-editor-matrix")
                } label: {
                    Label("Linked depth", systemImage: "square.grid.3x3")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(Color(hex: "#8DDDE8"))
                .padding(.top, 6)
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 36)
        }
        .frame(width: 248, alignment: .leading)
        .background(Color(hex: "#031014").opacity(0.72))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Chamber.dojo.color.opacity(0.72), Chamber.atlas.color.opacity(0.9), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1)
        }
    }

    private func statusItem(_ item: String) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Circle()
                .fill(item == "System details" ? Chamber.dojo.color : Chamber.atlas.color)
                .frame(width: 6, height: 6)
                .shadow(color: Chamber.atlas.color.opacity(0.7), radius: 5)

            Text(item)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(FieldPalette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private enum EntranceAction: String, CaseIterable, Identifiable {
    case captureThought
    case continueConversation
    case reviewSomething
    case attention

    var id: String { rawValue }

    var title: String {
        switch self {
        case .captureThought: return "Capture a thought"
        case .continueConversation: return "Continue a conversation"
        case .reviewSomething: return "Review something"
        case .attention: return "See what needs attention"
        }
    }

    var systemImage: String {
        switch self {
        case .captureThought: return "square.and.pencil"
        case .continueConversation: return "bubble.left.and.bubble.right"
        case .reviewSomething: return "doc.text.magnifyingglass"
        case .attention: return "exclamationmark.circle"
        }
    }

    var accent: Color {
        switch self {
        case .captureThought: return Chamber.atlas.color
        case .continueConversation: return Color(hex: "#60A5FA")
        case .reviewSomething: return Chamber.dojo.color
        case .attention: return Color(hex: "#A78BFA")
        }
    }
}

private struct TodayParticleAtmosphere: View {
    private let stars: [ParticlePoint] = [
        .init(x: 0.08, y: 0.18, size: 1.5, opacity: 0.52),
        .init(x: 0.18, y: 0.36, size: 1.1, opacity: 0.44),
        .init(x: 0.26, y: 0.12, size: 1.8, opacity: 0.38),
        .init(x: 0.42, y: 0.28, size: 1.2, opacity: 0.5),
        .init(x: 0.56, y: 0.14, size: 1.6, opacity: 0.34),
        .init(x: 0.70, y: 0.34, size: 1.0, opacity: 0.42),
        .init(x: 0.86, y: 0.20, size: 1.3, opacity: 0.48),
        .init(x: 0.14, y: 0.76, size: 1.7, opacity: 0.36),
        .init(x: 0.36, y: 0.84, size: 1.1, opacity: 0.46),
        .init(x: 0.62, y: 0.72, size: 1.5, opacity: 0.38),
        .init(x: 0.82, y: 0.82, size: 1.0, opacity: 0.44),
    ]

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "#031014"),
                        Color(hex: "#05242A"),
                        FieldPalette.void
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    colors: [Chamber.atlas.color.opacity(0.18), .clear],
                    center: .init(x: 0.78, y: 0.18),
                    startRadius: 40,
                    endRadius: max(size.width, size.height) * 0.75
                )

                Canvas { context, canvasSize in
                    drawCrystal(in: &context, size: canvasSize)
                    drawParticles(in: &context, size: canvasSize)
                }
            }
        }
        .ignoresSafeArea()
    }

    private func drawCrystal(in context: inout GraphicsContext, size: CGSize) {
        let points = [
            CGPoint(x: size.width * 0.58, y: size.height * 0.16),
            CGPoint(x: size.width * 0.86, y: size.height * 0.42),
            CGPoint(x: size.width * 0.70, y: size.height * 0.70),
            CGPoint(x: size.width * 0.45, y: size.height * 0.48)
        ]

        var outline = Path()
        outline.move(to: points[0])
        for point in points.dropFirst() {
            outline.addLine(to: point)
        }
        outline.closeSubpath()

        context.stroke(outline, with: .color(Chamber.dojo.color.opacity(0.34)), lineWidth: 1)

        for index in points.indices {
            var edge = Path()
            edge.move(to: points[index])
            edge.addLine(to: points[(index + 2) % points.count])
            context.stroke(edge, with: .color(Chamber.atlas.color.opacity(0.22)), lineWidth: 1)
        }
    }

    private func drawParticles(in context: inout GraphicsContext, size: CGSize) {
        for particle in stars {
            let rect = CGRect(
                x: size.width * particle.x,
                y: size.height * particle.y,
                width: particle.size,
                height: particle.size
            )
            context.fill(
                Path(ellipseIn: rect),
                with: .color(Color(hex: "#8DDDE8").opacity(particle.opacity))
            )
        }
    }
}

private struct ParticlePoint {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
}

#Preview("Apple Surface Matrix Candidate") {
    AppleSurfaceMatrixCandidateView()
        .frame(width: 1180, height: 820)
}

#Preview("Today / Capture Entrance") {
    TodayCaptureEntranceView()
        .frame(width: 980, height: 720)
}

#endif

import SwiftUI
#if canImport(FieldKit)
import FieldKit
#endif
#if canImport(DOJOShared)
import DOJOShared
#endif

struct PacketListView: View {
    @EnvironmentObject private var queue: PacketQueue
    @EnvironmentObject private var murmur: MurmurController
    @EnvironmentObject private var capture: MurmurCaptureService
    @State private var showCapture = false
    @State private var showEnqueueToast = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0A0A0C").ignoresSafeArea()

                if queue.packets.isEmpty {
                    FieldOrb()
                        .containerRelativeFrame([.horizontal]) { size, _ in size * 0.72 }
                        .aspectRatio(1, contentMode: .fit)
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
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
#endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        murmur.toggle()
                    } label: {
                        Image(systemName: capture.isCapturing ? "mic.fill" : "mic")
                            .foregroundStyle(capture.isCapturing ? Color(hex: "#EF4444") : Color(hex: "#7C3AED"))
                            .fontWeight(.semibold)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    let hasFailed = queue.packets.contains(where: { $0.state == .failed })
                    Button {
                        queue.resetFailed()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(Color(hex: "#F59E0B"))
                            .fontWeight(.semibold)
                    }
                    .opacity(hasFailed ? 1 : 0)
                    .disabled(!hasFailed)
                }
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
            .overlay(alignment: .top) {
                if showEnqueueToast {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                        Text("◼ murmur queued")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#7C3AED").opacity(0.9))
                    .clipShape(Capsule())
                    .padding(.top, 56)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .onChange(of: queue.packets.count) { old, new in
                guard new > old else { return }
                withAnimation(.spring(duration: 0.3)) { showEnqueueToast = true }
                Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    withAnimation(.easeOut(duration: 0.2)) { showEnqueueToast = false }
                }
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
            FieldCube()
                .frame(width: 38, height: 38)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 6) {
                if let voiceRef = packet.voiceRef, packet.textNotes.isEmpty {
                    Label("murmur · \(voiceRef.suffix(10))", systemImage: "mic")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(Color(hex: "#7C3AED"))
                        .lineLimit(1)
                } else {
                    Text(packet.textNotes.isEmpty ? "(no notes)" : packet.textNotes)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color(hex: "#E2E8F0"))
                        .lineLimit(2)
                }

                HStack(spacing: 8) {
                    Text(Self.dateFormatter.string(from: packet.createdAt))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color(hex: "#4B5563"))

                    Text("seal \(packet.integrityHash.prefix(8))")
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

// ── Field Cube ────────────────────────────────────────────────────────────────
// True isometric projection. Each packet is a cube — formed, solid, stackable.
// Three faces at exact luminance ratios. Light from upper-left. No approximation.
private struct FieldCube: View {
    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2
            let cy = size.height / 2
            // s = arm length (center to any vertex of the regular hexagonal silhouette)
            let s = min(size.width, size.height) * 0.46
            // w = horizontal arm (s * cos30° = s * √3/2)
            let w = s * 0.8660254037844386  // √3/2, exact

            // 7 key points — true isometric, 30° arms
            let top        = CGPoint(x: cx,     y: cy - s)
            let upperRight = CGPoint(x: cx + w, y: cy - s * 0.5)
            let upperLeft  = CGPoint(x: cx - w, y: cy - s * 0.5)
            let lowerRight = CGPoint(x: cx + w, y: cy + s * 0.5)
            let lowerLeft  = CGPoint(x: cx - w, y: cy + s * 0.5)
            let bottom     = CGPoint(x: cx,     y: cy + s)
            let mid        = CGPoint(x: cx,     y: cy)  // front+back corners coincide

            // ── Top face (brightest — faces the light) ───────────────────
            var topFace = Path()
            topFace.move(to: top)
            topFace.addLine(to: upperRight)
            topFace.addLine(to: mid)
            topFace.addLine(to: upperLeft)
            topFace.closeSubpath()
            ctx.fill(topFace, with: .color(Color(red: 0.19, green: 0.16, blue: 0.24)))

            // ── Right face (medium — partially lit) ─────────────────────
            var rightFace = Path()
            rightFace.move(to: mid)
            rightFace.addLine(to: upperRight)
            rightFace.addLine(to: lowerRight)
            rightFace.addLine(to: bottom)
            rightFace.closeSubpath()
            ctx.fill(rightFace, with: .color(Color(red: 0.10, green: 0.08, blue: 0.13)))

            // ── Left face (darkest — in shadow) ─────────────────────────
            var leftFace = Path()
            leftFace.move(to: mid)
            leftFace.addLine(to: upperLeft)
            leftFace.addLine(to: lowerLeft)
            leftFace.addLine(to: bottom)
            leftFace.closeSubpath()
            ctx.fill(leftFace, with: .color(Color(red: 0.05, green: 0.04, blue: 0.07)))

            // ── Silhouette edge ──────────────────────────────────────────
            var sil = Path()
            sil.move(to: top)
            sil.addLine(to: upperRight)
            sil.addLine(to: lowerRight)
            sil.addLine(to: bottom)
            sil.addLine(to: lowerLeft)
            sil.addLine(to: upperLeft)
            sil.closeSubpath()
            ctx.stroke(sil, with: .color(Color(white: 0.30, opacity: 0.35)),
                       style: StrokeStyle(lineWidth: 0.5, lineJoin: .miter))

            // ── Internal edges (3 arms from mid) ────────────────────────
            for dest in [top, lowerRight, lowerLeft] {
                var e = Path()
                e.move(to: mid)
                e.addLine(to: dest)
                ctx.stroke(e, with: .color(Color(white: 0.22, opacity: 0.30)), lineWidth: 0.4)
            }

            // ── Top-right edge highlight (catching light from upper-left) ─
            var hiEdge = Path()
            hiEdge.move(to: top)
            hiEdge.addLine(to: upperRight)
            ctx.stroke(hiEdge, with: .color(Color(white: 0.55, opacity: 0.58)), lineWidth: 0.7)

            // ── Top-left edge — secondary highlight ─────────────────────
            var hiLeft = Path()
            hiLeft.move(to: top)
            hiLeft.addLine(to: upperLeft)
            ctx.stroke(hiLeft, with: .color(Color(white: 0.38, opacity: 0.42)), lineWidth: 0.5)
        }
    }
}

// ── Field Orb ─────────────────────────────────────────────────────────────────
// Sphere with golden-ratio positioned interior — the field before a murmur enters it.
private struct FieldOrb: View {
    @State private var breath: CGFloat = 0.97
    private static let phi: CGFloat = 1.6180339887498948482

    var body: some View {
        Canvas { ctx, size in
            let phi = FieldOrb.phi
            let cx = size.width / 2
            let cy = size.height / 2
            let R = min(size.width, size.height) * 0.44

            // ── Sphere ──────────────────────────────────────────────────
            let spherePath = Path(ellipseIn: CGRect(x: cx - R, y: cy - R, width: R * 2, height: R * 2))

            // Base — limb darkening: lighter center, dark edge
            ctx.fill(spherePath, with: .radialGradient(
                Gradient(stops: [
                    .init(color: Color(red: 0.11, green: 0.09, blue: 0.14), location: 0),
                    .init(color: Color(red: 0.06, green: 0.05, blue: 0.08), location: 0.65),
                    .init(color: Color(red: 0.02, green: 0.01, blue: 0.03), location: 1.0),
                ]),
                center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: R
            ))

            // Highlight — offset 1/φ from center, upper-left
            let hDist = R / phi
            let hCenter = CGPoint(x: cx - hDist * 0.42, y: cy - hDist * 0.52)
            ctx.fill(spherePath, with: .radialGradient(
                Gradient(stops: [
                    .init(color: Color(white: 0.30, opacity: 0.32), location: 0),
                    .init(color: Color(white: 0.12, opacity: 0.08), location: 0.5),
                    .init(color: Color.clear, location: 1.0),
                ]),
                center: hCenter, startRadius: 0, endRadius: R * 0.68
            ))

            // Specular point
            let specR = R * 0.055
            let specC = CGPoint(x: cx - R * 0.38, y: cy - R * 0.43)
            ctx.fill(
                Path(ellipseIn: CGRect(x: specC.x - specR, y: specC.y - specR, width: specR * 2, height: specR * 2)),
                with: .radialGradient(
                    Gradient(stops: [.init(color: Color(white: 0.72, opacity: 0.5), location: 0), .init(color: .clear, location: 1)]),
                    center: specC, startRadius: 0, endRadius: specR
                )
            )

            // ── Opening ──────────────────────────────────────────────────
            // Two points on sphere edge define the aperture.
            // Positioned upper-right — opposite the highlight — tension by contrast.
            // Arc sweep is determined by golden angle proportion.
            let a1: CGFloat = -.pi * 0.55  // ≈ top of sphere (slightly left)
            let a2: CGFloat = .pi * 0.05   // ≈ right side (slightly below)
            let pA = CGPoint(x: cx + R * cos(a1), y: cy + R * sin(a1))
            let pB = CGPoint(x: cx + R * cos(a2), y: cy + R * sin(a2))

            // Fold bezier control points — inside sphere, creating concave return curve
            let fc1 = CGPoint(x: cx + R * 0.12, y: cy - R * 0.60)
            let fc2 = CGPoint(x: cx + R * 0.46, y: cy - R * 0.08)

            // Window: short arc (upper-right) + fold bezier back through interior
            var winPath = Path()
            winPath.move(to: pA)
            winPath.addArc(center: CGPoint(x: cx, y: cy), radius: R,
                           startAngle: .radians(a1), endAngle: .radians(a2), clockwise: true)
            winPath.addCurve(to: pA, control1: fc2, control2: fc1)
            winPath.closeSubpath()

            ctx.fill(winPath, with: .color(Color(red: 0.09, green: 0.06, blue: 0.12)))

            // Interior geometry — isolated layer, clipped to window
            ctx.drawLayer { inner in
                inner.clip(to: winPath)

                // Interior reference center at phi-ratio inside opening
                let iC = CGPoint(x: cx + R * 0.15, y: cy - R * 0.30)

                let r1 = R / (phi * phi)
                let r2 = R / pow(phi, 3)
                let r3 = R / pow(phi, 4)

                // Concentric rings at Fibonacci radii
                inner.stroke(
                    Path(ellipseIn: CGRect(x: iC.x - r1, y: iC.y - r1, width: r1 * 2, height: r1 * 2)),
                    with: .color(Color(white: 0.55, opacity: 0.17)), lineWidth: 0.4)
                inner.stroke(
                    Path(ellipseIn: CGRect(x: iC.x - r2, y: iC.y - r2, width: r2 * 2, height: r2 * 2)),
                    with: .color(Color(white: 0.55, opacity: 0.22)), lineWidth: 0.4)

                // One visible radius line at golden angle (≈ 137.5°) — the hint
                let goldenAngle: CGFloat = 2 * .pi / (phi * phi)
                var radPath = Path()
                radPath.move(to: iC)
                radPath.addLine(to: CGPoint(x: iC.x + r1 * cos(goldenAngle), y: iC.y + r1 * sin(goldenAngle)))
                inner.stroke(radPath, with: .color(Color(white: 0.50, opacity: 0.28)), lineWidth: 0.4)

                // Golden spiral — 1 turn, parametric, barely visible
                var spiral = Path()
                for i in 0...80 {
                    let t = CGFloat(i) / 80.0
                    let angle = t * .pi * 2
                    let r = (r3 * 0.4) * pow(phi, angle / (.pi / 2))
                    let pt = CGPoint(x: iC.x + r * cos(angle + .pi * 0.9),
                                     y: iC.y + r * sin(angle + .pi * 0.9))
                    if i == 0 { spiral.move(to: pt) } else { spiral.addLine(to: pt) }
                }
                inner.stroke(spiral, with: .color(Color(red: 0.55, green: 0.3, blue: 0.9, opacity: 0.20)), lineWidth: 0.5)

                // Murmur point ● — the only luminosity in the field
                let pR = R * 0.022
                let glowLevels: [CGFloat] = [4, 3, 2, 1.2, 1]
                for (i, mult) in glowLevels.enumerated() {
                    let gr = pR * mult
                    let op = Double(i) / 12.0
                    inner.fill(
                        Path(ellipseIn: CGRect(x: iC.x - gr, y: iC.y - gr, width: gr * 2, height: gr * 2)),
                        with: .color(Color(red: 0.50, green: 0.28, blue: 1.0, opacity: op))
                    )
                }
                inner.fill(
                    Path(ellipseIn: CGRect(x: iC.x - pR, y: iC.y - pR, width: pR * 2, height: pR * 2)),
                    with: .color(Color(red: 0.65, green: 0.42, blue: 1.0, opacity: 0.88))
                )
            }

            // Fold edge — sphere wall revealed at the opening, single dim stroke
            var foldEdge = Path()
            foldEdge.move(to: pA)
            foldEdge.addCurve(to: pB, control1: fc1, control2: fc2)
            ctx.stroke(foldEdge, with: .color(Color(white: 0.42, opacity: 0.52)), lineWidth: 0.7)

            // Outer sphere rim
            ctx.stroke(spherePath, with: .color(Color(white: 0.18, opacity: 0.12)), lineWidth: 0.5)
        }
        .scaleEffect(breath)
        .animation(.easeInOut(duration: 4.2).repeatForever(autoreverses: true), value: breath)
        .onAppear { breath = 1.0 }
    }
}

#Preview {
    let murmur = MurmurController()
    return PacketListView()
        .environmentObject(PacketQueue())
        .environmentObject(murmur)
        .environmentObject(murmur.captureService)
        .preferredColorScheme(.dark)
}

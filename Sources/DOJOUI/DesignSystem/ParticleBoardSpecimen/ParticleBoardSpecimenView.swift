import SwiftUI

@MainActor
public struct ParticleBoardSpecimenView: View {
    @State private var state: ParticleBoardVisualState = .quiet
    @State private var envelope: DraftManifestationEnvelope?
    @State private var particles = ParticleBoardSampleArtifact.particles()
    @State private var reduceMotion = false
    @State private var debugOverlay = false
    @State private var savedDraftIDs: [String] = []

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            ParticleBoardSpecimenFrame(
                state: state,
                envelope: envelope,
                particles: particlesForCurrentEnvelope,
                reduceMotion: reduceMotion,
                debugOverlay: debugOverlay
            )
            controls
        }
        .frame(minWidth: 980, minHeight: 720)
        .background(Color(hex: "#0A1A1A"))
    }

    private var particlesForCurrentEnvelope: [VisualParticle] {
        let count = envelope?.requestedFidelity.particleCount ?? ParticleBoardFidelity.photographic.particleCount
        if particles.count == count { return particles }
        return ParticleBoardSampleArtifact.particles(count: count)
    }

    private var controls: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                controlButton("Quiet") {
                    apply(.chooseQuiet)
                }
                controlButton("Lucid") {
                    apply(.chooseLucid)
                }
                Divider().frame(height: 22)
                controlButton("Introduce eligible draft") {
                    introduce(ParticleBoardSampleArtifact.eligibleEnvelope())
                }
                controlButton("Introduce HOLD draft") {
                    introduce(ParticleBoardSampleArtifact.heldEnvelope())
                }
                controlButton("Introduce Unknown draft") {
                    introduce(ParticleBoardSampleArtifact.unknownEnvelope())
                }
                controlButton("Reveal") {
                    revealStep()
                }
                controlButton("Revise", disabled: state != .revealed) {
                    apply(.revise)
                }
                controlButton("Save draft", disabled: state != .revealed) {
                    if let candidateID = envelope?.candidateID, !candidateID.isEmpty {
                        savedDraftIDs.append(candidateID)
                    }
                    apply(.saveDraft)
                }
                controlButton("Dismiss", disabled: state != .revealed && state != .revising) {
                    apply(.dismiss)
                }
            }
            HStack(spacing: 14) {
                Toggle("Reduce Motion", isOn: $reduceMotion)
                    .toggleStyle(.checkbox)
                Toggle("Debug overlay", isOn: $debugOverlay)
                    .toggleStyle(.checkbox)
                Spacer()
                Text("Saved in memory: \(savedDraftIDs.count)")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: "#A7F3F3"))
            }
        }
        .font(.system(size: 12, weight: .semibold, design: .rounded))
        .foregroundStyle(Color(hex: "#FAFAFA"))
        .padding(14)
        .background(Color(hex: "#061313"))
        .overlay(Rectangle().fill(Color(hex: "#1A7A7A").opacity(0.32)).frame(height: 1), alignment: .top)
    }

    private func controlButton(_ title: String, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .buttonStyle(.bordered)
            .disabled(disabled)
            .accessibilityLabel(title)
    }

    private func introduce(_ draft: DraftManifestationEnvelope) {
        envelope = draft
        particles = ParticleBoardSampleArtifact.particles(count: draft.requestedFidelity.particleCount)
        apply(.introduceDraft(draft))
    }

    private func revealStep() {
        if state == .receivingCandidate {
            apply(.evaluate)
            let decision = ParticleBoardStateMachine.evaluateCandidate(envelope)
            state = decision.state
            return
        }
        apply(.advance)
    }

    private func apply(_ event: ParticleBoardVisualEvent) {
        let decision = ParticleBoardStateMachine.reduce(state: state, event: event)
        if decision.accepted {
            state = decision.state
        }
    }
}

#if DEBUG
#Preview("ParticleBoard Aikido Optics Specimen") {
    ParticleBoardSpecimenView()
}
#endif

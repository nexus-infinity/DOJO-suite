import Foundation
import AVFoundation

// MARK: - DOJOFieldCoordinator

/// Layer 2 cognitive node — the bridge between HAL events and the Arkadaš persona.
///
/// Responsibilities:
///   1. Register and track murmors (the field's device registry)
///   2. Run FieldInvariant checks and publish coherence level
///   3. Feed every ConversationMessage into OBIWANState (close the observer gap)
///   4. Manage HALOutputProfile (routing) and FieldAudioMode (behavior) transitions
///   5. Speak character responses via AVSpeechSynthesizer, gated by audio mode
///   6. Dispatch ActCommands to anchor murmors based on confirmed coherence transitions
///
/// The coordinator wires itself to CopilotEngine at init via onMessageAppended.
/// The view does not need to know about this — the engine just calls the hook.
@MainActor
public final class DOJOFieldCoordinator: ObservableObject {

    // MARK: - Published State

    @Published public private(set) var fieldCoherence: CoherenceLevel = .coherent
    @Published public private(set) var audioMode: FieldAudioMode = .full
    @Published public private(set) var activeProfile: HALOutputProfile = .broadcast
    @Published public private(set) var activePhase: DOJOPhase = .idle
    @Published public private(set) var registeredMurmors: [MurmorIdentity] = []

    // MARK: - Dependencies

    private let engine: CopilotEngine
    private let observer: OBIWANState

    // MARK: - Registry

    private var registry: [UUID: any DOJOMurmor] = [:]

    // MARK: - Monitoring

    private var monitoringTask: Task<Void, Never>?
    private let invariantIntervalSeconds: Double = 30

    // Hysteresis: requires 2 consecutive evaluations at the same level before
    // dispatching ActCommands. Prevents oscillation on borderline field states.
    private var coherenceTracker = CoherenceStateTracker()

    // MARK: - Audio

    private let synthesizer = AVSpeechSynthesizer()

    // MARK: - Init

    public init(engine: CopilotEngine, observer: OBIWANState) {
        self.engine = engine
        self.observer = observer

        // Wire the observer gap: every engine message flows through here
        engine.onMessageAppended = { [weak self] message in
            self?.handleMessage(message)
        }
    }

    /// Convenience: uses the shared OBIWANState singleton.
    /// Must be called from a @MainActor context (OBIWANState.shared is @MainActor).
    public convenience init(engine: CopilotEngine) {
        self.init(engine: engine, observer: OBIWANState.shared)
    }

    // MARK: - Murmor Registry

    public func register(_ murmor: any DOJOMurmor) {
        registry[murmor.identity.id] = murmor
        registeredMurmors = registry.values.map(\.identity)
        evaluateInvariant()
        evaluateProfileSwitch()
        print("◆ Coordinator: registered \(murmor.identity.name) [\(murmor.identity.deviceClass.rawValue)]")
    }

    public func deregister(id: UUID) {
        guard let murmor = registry.removeValue(forKey: id) else { return }
        registeredMurmors = registry.values.map(\.identity)
        evaluateInvariant()
        evaluateProfileSwitch()
        print("◆ Coordinator: deregistered \(murmor.identity.name)")
    }

    // MARK: - Convenience: Register the local Mac

    public func registerMacMurmor(name: String = "Mac") {
        let mac = MacMurmor(name: name)
        let identity = mac.identity
        // Mark as active immediately — it's the device we're running on
        let activeIdentity = MurmorIdentity(
            id: identity.id,
            name: identity.name,
            deviceClass: identity.deviceClass,
            profile: identity.profile,
            state: .active
        )
        registry[activeIdentity.id] = mac
        registeredMurmors = registry.values.map(\.identity)
        evaluateInvariant()
        evaluateProfileSwitch()
        print("◆ Coordinator: Mac murmor online [\(activeIdentity.id)]")
    }

    // MARK: - HAL Event Ingestion

    /// Called by murmors or sensors to inject a field event.
    public func ingest(_ event: SenseEvent) {
        activePhase = .observe
        recordObserverTag(event)

        switch event.senseType {
        case .presenceChange, .motion:
            evaluateProfileSwitch()
        default:
            break
        }

        activePhase = .orient
    }

    // MARK: - Conversation Observer Feed (closes the observer gap)

    private func handleMessage(_ message: ConversationMessage) {
        // Record in OBIWANState
        let tag: String
        if message.isUser {
            tag = "user: \(message.text.prefix(60))"
        } else {
            let char = message.character?.rawValue ?? "system"
            tag = "\(char): \(message.text.prefix(60))"
        }
        observer.recordObservation(tag)

        // Advance O₁→O₂→O₃ phase on each completed turn
        let next: DOJOPhase
        switch activePhase {
        case .idle:    next = .observe
        case .observe: next = .orient
        case .orient:  next = .operate
        case .operate: next = .idle
        }
        activePhase = next

        // Mirror into OBIWANState's Tesla 3-6-9 phase
        let teslaPhase: Int
        switch activePhase {
        case .observe: teslaPhase = 3
        case .orient:  teslaPhase = 6
        case .operate, .idle: teslaPhase = 9
        }
        observer.setPhase(teslaPhase)

        // Speak character responses — gated by current audio mode
        if !message.isUser, let character = message.character {
            speakResponse(message.text, as: character)
        }
    }

    // MARK: - Invariant Evaluation

    private func evaluateInvariant() {
        let identities = registry.values.map(\.identity)
        let reading = ObserverReading(
            timestamp: Date(),
            alignment: observer.alignment,
            phase: activePhase
        )
        let snapshot = FieldStateSnapshot(
            coherenceLevel: fieldCoherence,
            activePhase: activePhase,
            activeMurmors: identities.map(\.id),
            lastObserverReading: reading
        )
        let result = FieldInvariant(registry: identities, currentState: snapshot).evaluate()

        // Always update displayed coherence immediately (UI accuracy)
        fieldCoherence = result.coherenceLevel

        // Only dispatch ActCommands on confirmed stable transitions (hysteresis)
        guard let confirmedLevel = coherenceTracker.update(with: result.coherenceLevel) else { return }

        // Confirmed transition — push new state to all murmors (Rule 2)
        let newSnapshot = FieldStateSnapshot(
            coherenceLevel: confirmedLevel,
            activePhase: activePhase,
            activeMurmors: identities.map(\.id),
            lastObserverReading: reading
        )
        for murmor in registry.values {
            murmor.lastKnownFieldState = newSnapshot
        }

        switch confirmedLevel {
        case .coherent:  dispatchActCommand(.indicateCoherent)
        case .degraded:  dispatchActCommand(.indicateDegraded)
        case .drifting:  dispatchActCommand(.indicateDrifting)
        case .breached:  dispatchActCommand(.indicateBreached)
        }
    }

    // MARK: - ActCommand Dispatch

    private func dispatchActCommand(_ command: ActCommand) {
        print("◆ Coordinator → \(command.rawValue)")
        handleConfirmedTransition(command)
        // Phase 2: also route through DOJORelay to anchor murmors
    }

    /// Maps confirmed CoherenceLevel transitions to audio mode changes.
    /// Only called on stable transitions from CoherenceStateTracker.
    /// UI state (fieldCoherence) is updated independently of this.
    private func handleConfirmedTransition(_ command: ActCommand) {
        switch command {

        case .indicateCoherent:
            // Full field — all audio paths active, AI speech at full confidence
            audioMode = .full

        case .indicateDegraded:
            // Can act but no dedicated sensing — output continues, ambient suspended
            audioMode = .outputOnly

        case .indicateDrifting:
            // Field losing alignment — stop assertive AI speech, passthrough only
            audioMode = .passthrough
            synthesizer.stopSpeaking(at: .word)  // finish current word, then stop

        case .indicateBreached:
            // No cognitive node — field offline, silence all AI output
            audioMode = .silent
            synthesizer.stopSpeaking(at: .immediate)

        default:
            break
        }
    }

    // MARK: - HAL Output Profile

    public func setProfile(_ profile: HALOutputProfile) {
        guard profile != activeProfile else { return }
        let previous = activeProfile
        activeProfile = profile
        print("◆ Coordinator: profile \(previous.rawValue) → \(profile.rawValue)")
    }

    private func evaluateProfileSwitch() {
        // Home field: any active Mac or AppleTV murmor → broadcast via TV Connector
        let hasHomeAnchor = registry.values.contains {
            ($0.identity.deviceClass == .mac || $0.identity.deviceClass == .appleTV) &&
            $0.identity.state == .active
        }
        setProfile(hasHomeAnchor ? .broadcast : .intimate)
    }

    // MARK: - TTS

    private func speakResponse(_ text: String, as character: GeometricCharacter) {
        switch audioMode {
        case .full, .outputOnly:
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = voice(for: character)
            utterance.rate = 0.46   // slightly below default 0.5 — more presence
            synthesizer.speak(utterance)

        case .passthrough, .silent:
            break  // Field doesn't trust its own state — no assertive AI speech
        }
    }

    /// Looks up the system voice matching the character's configured name.
    /// Falls back to en-AU locale if the named voice isn't installed.
    private func voice(for character: GeometricCharacter) -> AVSpeechSynthesisVoice? {
        AVSpeechSynthesisVoice.speechVoices().first { $0.name == character.macOSVoice }
            ?? AVSpeechSynthesisVoice(language: "en-AU")
    }

    // MARK: - Private Helpers

    private func recordObserverTag(_ event: SenseEvent) {
        let value = event.payload.categoricalValue
            ?? event.payload.numericValue.map { String(format: "%.1f", $0) }
            ?? "—"
        observer.recordObservation("\(event.senseType.rawValue):\(value)")
    }

    // MARK: - Periodic Invariant Monitoring

    public func startInvariantMonitoring() {
        guard monitoringTask == nil else { return }
        monitoringTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(self?.invariantIntervalSeconds ?? 30))
                self?.evaluateInvariant()
            }
        }
        print("◆ Coordinator: invariant monitoring started (\(Int(invariantIntervalSeconds))s interval)")
    }

    public func stopInvariantMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = nil
    }
}

import Foundation
import AVFoundation
import Combine

@MainActor
public final class DOJOFieldCoordinator: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {

    @Published public private(set) var fieldCoherence: CoherenceLevel = .coherent
    @Published public private(set) var audioMode: FieldAudioMode = .full
    @Published public private(set) var activeProfile: HALOutputProfile = .broadcast
    @Published public private(set) var activePhase: DOJOPhase = .idle
    @Published public private(set) var registeredMurmors: [MurmorIdentity] = []
    @Published public private(set) var keeperVerdict: KeeperVerdict = .initialising

    private let engine: CopilotEngine
    private let observer: OBIWANState
    public let micBridge: VADMicBridge
    public let envMonitor: HALEnvironmentMonitor

    private var registry: [UUID: any DOJOMurmor] = [:]
    private var monitoringTask: Task<Void, Never>?
    private let invariantIntervalSeconds: Double = 30
    private var coherenceTracker = CoherenceStateTracker()
    private var cancellables = Set<AnyCancellable>()

    private let synthesizer = AVSpeechSynthesizer()
    private var activeSpeechUtterance: AVSpeechUtterance?

    public init(engine: CopilotEngine, observer: OBIWANState, micBridge: VADMicBridge, envMonitor: HALEnvironmentMonitor) {
        self.engine = engine
        self.observer = observer
        self.micBridge = micBridge
        self.envMonitor = envMonitor
        super.init()
        
        self.synthesizer.delegate = self

        engine.onMessageAppended = { [weak self] message in
            self?.handleMessage(message)
        }
        
        // Wire the VAD into the CopilotEngine
        micBridge.onUtterance = { [weak self] transcript in
            Task { @MainActor [weak self] in
                await self?.engine.process(input: transcript)
            }
        }
        
        // Wire the Environment Monitor into the Profile Switcher
        envMonitor.$isBluetoothAudioConnected
            .dropFirst()
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in self?.evaluateProfileSwitch() }
            }
            .store(in: &cancellables)
            
        envMonitor.$isWifiConnected
            .dropFirst()
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in self?.evaluateProfileSwitch() }
            }
            .store(in: &cancellables)

        micBridge.$isPausedForOutput
            .dropFirst()
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in self?.updateKeeperVerdict() }
            }
            .store(in: &cancellables)

        updateKeeperVerdict()
    }

    public convenience init(engine: CopilotEngine) {
        self.init(engine: engine, observer: OBIWANState.shared, micBridge: VADMicBridge(), envMonitor: HALEnvironmentMonitor())
    }

    public func register(_ murmor: any DOJOMurmor) {
        registry[murmor.identity.id] = murmor
        registeredMurmors = registry.values.map(\.identity)
        evaluateInvariant()
        evaluateProfileSwitch()
    }

    public func deregister(id: UUID) {
        guard registry.removeValue(forKey: id) != nil else { return }
        registeredMurmors = registry.values.map(\.identity)
        evaluateInvariant()
        evaluateProfileSwitch()
    }

    public func registerMacMurmor(name: String = "Mac") {
        let mac = MacMurmor(name: name)
        let identity = mac.identity
        var activeIdentity = MurmorIdentity(
            id: identity.id,
            name: identity.name,
            deviceClass: identity.deviceClass,
            profile: identity.profile,
            state: .active
        )
        activeIdentity.lastSyncTimestamp = Date()
        mac.identity = activeIdentity
        registry[activeIdentity.id] = mac
        registeredMurmors = registry.values.map(\.identity)
        evaluateInvariant()
        evaluateProfileSwitch()
    }

    public func ingest(_ event: SenseEvent) {
        activePhase = .observe
        recordObserverTag(event)
        switch event.senseType {
        case .presenceChange, .motion: evaluateProfileSwitch()
        default: break
        }
        activePhase = .orient
    }

    private func handleMessage(_ message: ConversationMessage) {
        let tag = message.isUser ? "user: \(message.text.prefix(60))" : "\(message.character?.rawValue ?? "system"): \(message.text.prefix(60))"
        observer.recordObservation(tag)

        let next: DOJOPhase
        switch activePhase {
        case .idle:    next = .observe
        case .observe: next = .orient
        case .orient:  next = .operate
        case .operate: next = .idle
        }
        activePhase = next

        let teslaPhase: Int
        switch activePhase {
        case .observe: teslaPhase = 3
        case .orient:  teslaPhase = 6
        case .operate, .idle: teslaPhase = 9
        }
        observer.setPhase(teslaPhase)

        if !message.isUser, let character = message.character {
            speakResponse(message.text, as: character)
        }
    }

    private func evaluateInvariant() {
        let identities = registry.values.map(\.identity)
        let reading = ObserverReading(timestamp: Date(), alignment: observer.alignment, phase: activePhase)
        let snapshot = FieldStateSnapshot(coherenceLevel: fieldCoherence, activePhase: activePhase, activeMurmors: identities.map(\.id), lastObserverReading: reading)
        let result = FieldInvariant(registry: identities, currentState: snapshot).evaluate()

        fieldCoherence = result.coherenceLevel
        updateKeeperVerdict()

        guard let confirmedLevel = coherenceTracker.update(with: result.coherenceLevel) else { return }

        let newSnapshot = FieldStateSnapshot(coherenceLevel: confirmedLevel, activePhase: activePhase, activeMurmors: identities.map(\.id), lastObserverReading: reading)
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

    private func dispatchActCommand(_ command: ActCommand) {
        print("◆ Coordinator → \(command.rawValue)")
        
        let newMode: FieldAudioMode
        switch command {
        case .indicateCoherent: newMode = .full
        case .indicateDegraded: newMode = .outputOnly
        case .indicateDrifting: newMode = .passthrough
        case .indicateBreached: newMode = .silent
        default: return
        }
        
        applyTransition(mode: newMode, profile: activeProfile)
    }

    public func setProfile(_ profile: HALOutputProfile) {
        guard profile != activeProfile else { return }
        applyTransition(mode: audioMode, profile: profile)
    }

    private func evaluateProfileSwitch() {
        // 1. Hardware Bluetooth connection strictly forces Intimate profile
        if envMonitor.isBluetoothAudioConnected {
            setProfile(.intimate)
            return
        }
        
        // 2. Wi-Fi connection or known Home anchor heavily implies Broadcast/Fallback
        let hasHomeAnchor = registry.values.contains {
            ($0.identity.deviceClass == .mac || $0.identity.deviceClass == .appleTV) &&
            $0.identity.state == .active
        }
        
        if hasHomeAnchor {
            setProfile(.broadcast)
        } else if envMonitor.isWifiConnected {
            setProfile(.fallback) // Home network without explicit anchor
        } else {
            setProfile(.fallback) // Conservative default
        }
    }
    
    // MARK: - Unified Transition Gate
    
    public func applyTransition(mode: FieldAudioMode, profile: HALOutputProfile) {
        let previousMode = audioMode
        let previousProfile = activeProfile
        
        audioMode = mode
        activeProfile = profile
        updateKeeperVerdict()

        if mode != previousMode || profile != previousProfile {
            print("◆ HAL Audio: Mode [\(mode.rawValue)] | Profile [\(profile.rawValue)]")
            
            // 1. Tear down / Pause output if needed
            if mode == .silent || mode == .passthrough {
                synthesizer.stopSpeaking(at: mode == .silent ? .immediate : .word)
            }
            
            // 2. Reconfigure AVAudioSession and MicBridge
            do {
                if mode == .full || mode == .passthrough {
                    if !micBridge.isListening {
                        try micBridge.start(profile: profile)
                    } else {
                        try micBridge.configureAudioSession(for: profile)
                    }
                } else {
                    micBridge.stop()
                    if mode == .outputOnly {
                        try micBridge.configureAudioSession(for: profile)
                    }
                }
            } catch {
                print("◆ HAL Error: Failed to transition audio state: \(error)")
            }
        }
    }

    // MARK: - TTS & Ducking

    private func speakResponse(_ text: String, as character: GeometricCharacter) {
        switch audioMode {
        case .full, .outputOnly:
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = voice(for: character)
            utterance.rate = 0.46
            activeSpeechUtterance = utterance
            // AVSpeechSynthesizer.speak() calls DispatchQueue.main.sync internally.
            // Scheduling via main.async breaks out of the Swift Task context and
            // prevents the "unsafeForcedSync" runtime warning.
            DispatchQueue.main.async { [weak self] in
                guard let self, let utterance = self.activeSpeechUtterance else { return }
                self.synthesizer.speak(utterance)
            }
        case .passthrough, .silent:
            break
        }
    }

    private func voice(for character: GeometricCharacter) -> AVSpeechSynthesisVoice? {
        AVSpeechSynthesisVoice.speechVoices().first { $0.name == character.macOSVoice }
            ?? AVSpeechSynthesisVoice(language: "en-AU")
    }
    
    nonisolated public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            print("◆ HAL: Ducking mic for AI speech output")
            micBridge.pauseForOutput()
        }
    }
    
    nonisolated public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            print("◆ HAL: Resuming mic after AI speech output")
            micBridge.resumeAfterOutput()
            activeSpeechUtterance = nil
        }
    }
    
    nonisolated public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            micBridge.resumeAfterOutput()
            activeSpeechUtterance = nil
        }
    }

    // MARK: - Keeper Verdict

    private func updateKeeperVerdict() {
        let count = registeredMurmors.count
        let noun = count == 1 ? "device" : "devices"

        switch fieldCoherence {
        case .coherent:
            let route: String
            if envMonitor.isBluetoothAudioConnected {
                route = "BT · \(activeProfile.rawValue)"
            } else if envMonitor.isWifiConnected {
                route = "home · \(activeProfile.rawValue)"
            } else {
                route = activeProfile.rawValue
            }
            keeperVerdict = KeeperVerdict(
                state: .aligned,
                summary: "\(count) \(noun) · \(route) · \(audioMode.rawValue)."
            )

        case .degraded:
            keeperVerdict = KeeperVerdict(
                state: .degraded,
                summary: micBridge.isPausedForOutput
                    ? "Mic paused — output in progress."
                    : "Output only — no dedicated sensing layer."
            )

        case .drifting:
            keeperVerdict = KeeperVerdict(
                state: .hold,
                summary: "Hold — output path missing or sync stale."
            )

        case .breached:
            keeperVerdict = KeeperVerdict(
                state: .hold,
                summary: "Hold — no cognitive node. Field cannot orient."
            )
        }
    }

    // MARK: - Private Helpers

    private func recordObserverTag(_ event: SenseEvent) {
        let value = event.payload.categoricalValue ?? event.payload.numericValue.map { String(format: "%.1f", $0) } ?? "—"
        observer.recordObservation("\(event.senseType.rawValue):\(value)")
    }

    public func startInvariantMonitoring() {
        guard monitoringTask == nil else { return }
        monitoringTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(self?.invariantIntervalSeconds ?? 30))
                self?.evaluateInvariant()
            }
        }
    }

    public func stopInvariantMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = nil
    }
}

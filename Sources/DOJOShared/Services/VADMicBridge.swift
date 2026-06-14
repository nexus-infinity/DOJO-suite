import Accelerate

import Foundation
import AVFoundation
import Speech

@MainActor
public final class VADMicBridge: ObservableObject {

    @Published public var isListening = false
    @Published public var liveTranscript = ""
    @Published public var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    /// Set to the completed utterance text when speech ends. Resets to "" after each firing.
    /// SwiftUI views can observe this via `.onChange(of: micBridge.completedUtterance)`.
    @Published public var completedUtterance: String = ""

    public var onUtterance: ((String) -> Void)?

    private let silenceWindowSeconds: TimeInterval = 0.9
    private let calibrationSeconds: TimeInterval = 1.5

    private let engine = AVAudioEngine()
    private var recognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    private var silenceTask: Task<Void, Never>?
    private var calibrationTask: Task<Void, Never>?
    private var isCalibrating = false
    private var calibrationSamples: [Float] = []
    private var ambientBaseline: Float = 0.01
    private var isSpeechActive = false
    
    // Support pausing without tearing down the session (Ducking)
    @Published public private(set) var isPausedForOutput = false

    public init(locale: Locale = .current) {
        recognizer = SFSpeechRecognizer(locale: locale)
        recognizer?.defaultTaskHint = .dictation
    }

    public func requestAuthorization() async {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        authorizationStatus = status
    }

    public func start(profile: HALOutputProfile = .fallback) throws {
        guard !isListening else { return }
        guard authorizationStatus == .authorized else {
            throw VADError.notAuthorized
        }
        guard let recognizer, recognizer.isAvailable else {
            throw VADError.recognizerUnavailable
        }

        try configureAudioSession(for: profile)
        try beginRecognition(recognizer: recognizer)
        beginCalibration()
        isListening = true
    }

    public func stop() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        silenceTask?.cancel()
        calibrationTask?.cancel()
        isListening = false
        isSpeechActive = false
        isPausedForOutput = false
        liveTranscript = ""
    }
    
    public func pauseForOutput() {
        guard isListening else { return }
        isPausedForOutput = true
        engine.pause()
    }
    
    public func resumeAfterOutput() {
        guard isListening, isPausedForOutput else { return }
        isPausedForOutput = false
        try? engine.start()
    }

    public func configureAudioSession(for profile: HALOutputProfile) throws {
#if os(iOS)
        let session = AVAudioSession.sharedInstance()
        var options: AVAudioSession.CategoryOptions = [.duckOthers]
        
        switch profile {
        case .intimate:
            options.insert(.allowBluetoothHFP)
            options.insert(.allowBluetoothA2DP)
        case .fallback:
            options.insert(.defaultToSpeaker)
        case .broadcast, .ambient:
            // Standard measurement routing
            break
        }
        
        try session.setCategory(.playAndRecord, mode: .voiceChat, options: options)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
#endif
    }

    private func beginRecognition(recognizer: SFSpeechRecognizer) throws {
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = true
        recognitionRequest = request

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let result {
                    let text = result.bestTranscription.formattedString
                    self.liveTranscript = text
                    self.speechDetected()
                }
                if let error {
                    let nsError = error as NSError
                    let isTimeout = nsError.code == 1110 || nsError.code == 203
                    if isTimeout && self.isListening {
                        self.restartRecognition()
                    }
                }
            }
        }

        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            // Route buffer to speech recognizer immediately
            self?.recognitionRequest?.append(buffer)
            // Route to energy measurement on the main actor to avoid threading issues
            Task { @MainActor [weak self] in
                self?.measureEnergy(buffer: buffer)
            }
        }

        engine.prepare()
        try engine.start()
    }

    private func measureEnergy(buffer: AVAudioPCMBuffer) {
        guard !isPausedForOutput else { return }
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        guard frameLength > 0 else { return }

        var rms: Float = 0.0
        vDSP_rmsqv(channelData, 1, &rms, vDSP_Length(frameLength))

        if isCalibrating {
            calibrationSamples.append(rms)
            return
        }

        let dynamicThreshold = ambientBaseline * 1.5
        if rms > dynamicThreshold && !isSpeechActive {
            isSpeechActive = true
            silenceTask?.cancel()
        }
    }

    private func speechDetected() {
        isSpeechActive = true
        silenceTask?.cancel()

        silenceTask = Task { [weak self] in
            guard let self = self else { return }
            try? await Task.sleep(nanoseconds: UInt64(self.silenceWindowSeconds * 1_000_000_000))
            guard !Task.isCancelled else { return }

            if self.isSpeechActive, !self.liveTranscript.isEmpty {
                let final = self.liveTranscript
                self.onUtterance?(final)
                self.completedUtterance = final
                self.liveTranscript = ""
                self.restartRecognition()
            }
            self.isSpeechActive = false
        }
    }

    private func beginCalibration() {
        isCalibrating = true
        calibrationSamples = []

        calibrationTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64((self?.calibrationSeconds ?? 1.5) * 1_000_000_000))
            guard let self = self, !Task.isCancelled else { return }

            if !self.calibrationSamples.isEmpty {
                let sum = self.calibrationSamples.reduce(0, +)
                self.ambientBaseline = max(sum / Float(self.calibrationSamples.count), 0.01)
            }
            self.isCalibrating = false
        }
    }

    private func restartRecognition() {
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        guard isListening else { return }

        if let recognizer = recognizer, recognizer.isAvailable {
            try? beginRecognition(recognizer: recognizer)
        }
    }
}

public enum VADError: Error {
    case notAuthorized
    case recognizerUnavailable
}

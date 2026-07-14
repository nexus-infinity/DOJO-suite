import AVFoundation
import Foundation
#if canImport(DOJOShared)
import DOJOShared
#endif

/// Owns the murmur capture pipeline for the iOS app.
/// Creates Transport → Queue → CaptureService and manages the capture lifecycle.
/// On session end: seals MFC-01 voice object (durable audio + hash) and bridges → PacketQueue.
@MainActor
final class MurmurController: ObservableObject {

    let captureService: MurmurCaptureService

    /// Legacy session ref (UI/session id only — NOT evidence). Prefer `lastSealedVoiceObject`.
    @Published private(set) var completedSessionRef: String? = nil

    /// MFC-01 sealed offline voice object from the last completed capture (evidence spine).
    @Published private(set) var lastSealedVoiceObject: SealedVoiceObject? = nil

    private let deviceID: String

    init() {
        deviceID = Self.resolveDeviceID()
        let transport = MurmurTransport(deviceID: deviceID)
        let queue = MurmurQueue(transport: transport)
        captureService = MurmurCaptureService(deviceID: deviceID, queue: queue)
    }

    func toggle() {
        if captureService.isCapturing {
            finishCapture()
        } else {
            Task {
                let granted = await AVAudioApplication.requestRecordPermission()
                guard granted else { return }
                try? captureService.start()
            }
        }
    }

    /// Stops capture gracefully when the app backgrounds.
    func stopForBackground() {
        guard captureService.isCapturing else { return }
        finishCapture()
    }

    // MARK: - Private

    private func finishCapture() {
        captureService.stop()
        // Prefer sealed object from capture service (original bytes + SHA-256).
        if let sealed = captureService.lastSealedVoiceObject {
            lastSealedVoiceObject = sealed
            completedSessionRef = sealed.sealed_object_ref
            GeometryGateReceipt(
                sessionRef: sealed.sealed_object_ref,
                capability: "ios.mic.capture.mfc01_sealed",
                audioHashPrefix: String(sealed.audio_hash.prefix(16))
            ).log()
        } else {
            // No audio bytes captured — do not invent evidence; session ref is UI-only.
            let ref = "\(deviceID):\(Int(Date().timeIntervalSince1970))"
            completedSessionRef = ref
            lastSealedVoiceObject = nil
            GeometryGateReceipt(sessionRef: ref, capability: "ios.mic.capture.empty", audioHashPrefix: "none").log()
        }
    }

    private static func resolveDeviceID() -> String {
        let key = "field.murmur.device.id"
        if let id = UserDefaults.standard.string(forKey: key) { return id }
        let id = UUID().uuidString
        UserDefaults.standard.set(id, forKey: key)
        return id
    }
}

// Local capability log — not an AKRON receipt.
private struct GeometryGateReceipt: Codable {
    let sessionRef: String
    let timestamp: Date
    let capability: String
    let audioHashPrefix: String

    init(sessionRef: String, capability: String, audioHashPrefix: String) {
        self.sessionRef = sessionRef
        self.timestamp = Date()
        self.capability = capability
        self.audioHashPrefix = audioHashPrefix
    }

    func log() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        var log = UserDefaults.standard.array(forKey: "field.geometry.gate.log") as? [Data] ?? []
        log.append(data)
        if log.count > 50 { log.removeFirst(log.count - 50) }
        UserDefaults.standard.set(log, forKey: "field.geometry.gate.log")
    }
}

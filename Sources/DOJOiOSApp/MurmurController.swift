import AVFoundation
import Foundation

/// Owns the murmur capture pipeline for the iOS app.
/// Creates Transport → Queue → CaptureService and manages the capture lifecycle.
/// On session end: fires completedSessionRef so DOJOiOSApp can bridge → PacketQueue.
@MainActor
final class MurmurController: ObservableObject {

    let captureService: MurmurCaptureService

    /// Fires with a voice-session ref ("<deviceID>:<unix_ts>") each time recording stops.
    /// Observed by DOJOiOSApp to bridge completed murmur sessions → PacketQueue.
    @Published private(set) var completedSessionRef: String? = nil

    private let deviceID: String

    init() {
        deviceID = Self.resolveDeviceID()
        let transport = MurmurTransport(deviceID: deviceID)
        let queue = MurmurQueue(transport: transport)
        captureService = MurmurCaptureService(deviceID: deviceID, queue: queue)
    }

    func toggle() {
        if captureService.isCapturing {
            let ref = endSession()
            captureService.stop()
            completedSessionRef = ref
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
        let ref = endSession()
        captureService.stop()
        completedSessionRef = ref
    }

    // MARK: - Private

    private func endSession() -> String {
        let ref = "\(deviceID):\(Int(Date().timeIntervalSince1970))"
        GeometryGateReceipt(sessionRef: ref, capability: "ios.mic.capture").log()
        return ref
    }

    private static func resolveDeviceID() -> String {
        let key = "field.murmur.device.id"
        if let id = UserDefaults.standard.string(forKey: key) { return id }
        let id = UUID().uuidString
        UserDefaults.standard.set(id, forKey: key)
        return id
    }
}

// v0 stub — records capability proof locally; upgrade to AKRON signed receipt in v1.
private struct GeometryGateReceipt: Codable {
    let sessionRef: String
    let timestamp: Date
    let capability: String
    let sha256Hint: String  // first 8 chars of sessionRef as v0 placeholder

    init(sessionRef: String, capability: String) {
        self.sessionRef = sessionRef
        self.timestamp = Date()
        self.capability = capability
        self.sha256Hint = String(sessionRef.prefix(8))
    }

    func log() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        var log = UserDefaults.standard.array(forKey: "field.geometry.gate.log") as? [Data] ?? []
        log.append(data)
        if log.count > 50 { log.removeFirst(log.count - 50) }
        UserDefaults.standard.set(log, forKey: "field.geometry.gate.log")
    }
}

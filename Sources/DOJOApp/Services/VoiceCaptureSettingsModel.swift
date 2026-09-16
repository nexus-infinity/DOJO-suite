import Foundation
import AVFoundation
import Combine
import AppKit
import DOJOShared

#if os(macOS)
import CoreAudio

// MARK: - Voice & capture Settings model (Mac first)
// Handshake rule: only surface enhanced-hearing / multi-mic controls when a
// connected device advertises that capability. Prefer system default otherwise.
// Capture path genotype: mic → MurmurPacket / SealedVoice → (ASR layer) → text object.
// Layers not collapsed: capture ≠ transcription ≠ hosted model ≠ FIELD authority.

@MainActor
final class VoiceCaptureSettingsModel: ObservableObject {

    @Published private(set) var micPermission: MicPermissionStatus = .unknown
    @Published private(set) var inputDevices: [SelectableAudioDevice] = []
    @Published private(set) var outputDevices: [SelectableAudioDevice] = []
    @Published var preferredInputID: String = VoiceCapturePreferences.preferredInputID
    @Published var preferredOutputID: String = VoiceCapturePreferences.preferredOutputID
    @Published private(set) var isTesting = false
    @Published private(set) var testLevelDb: Float = -96
    @Published private(set) var testMessage = ""
    @Published private(set) var lastTestAt: Date?

    private var levelTimer: Timer?
    private var testEngine: AVAudioEngine?

    enum MicPermissionStatus: String {
        case unknown = "Unknown"
        case granted = "Allowed"
        case denied = "Denied"
        case restricted = "Restricted"

        var isUsable: Bool { self == .granted }
    }

    init() {
        refreshPermission()
        refreshDevices()
    }

    // MARK: - Permission

    func refreshPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            micPermission = .granted
        case .denied:
            micPermission = .denied
        case .restricted:
            micPermission = .restricted
        case .notDetermined:
            micPermission = .unknown
        @unknown default:
            micPermission = .unknown
        }
    }

    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            Task { @MainActor in
                self?.micPermission = granted ? .granted : .denied
                if granted {
                    self?.refreshDevices()
                }
            }
        }
    }

    func openSystemPrivacySettings() {
        // macOS Privacy → Microphone
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
            NSWorkspace.shared.open(url)
        }
    }

    func openSystemSoundSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.sound") {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Devices + capability handshake

    func refreshDevices() {
        inputDevices = Self.enumerateInputs()
        outputDevices = Self.enumerateOutputs()

        // Drop preferences that no longer exist (handshake: gone device → hide prefs)
        if preferredInputID != "system",
           !inputDevices.contains(where: { $0.id == preferredInputID }) {
            preferredInputID = "system"
            VoiceCapturePreferences.preferredInputID = "system"
        }
        if preferredOutputID != "system",
           !outputDevices.contains(where: { $0.id == preferredOutputID }) {
            preferredOutputID = "system"
            VoiceCapturePreferences.preferredOutputID = "system"
        }
    }

    /// Enhanced-hearing / multi-mic UI only when a **connected** device reports capability.
    var connectedEnhancedHearingDevices: [SelectableAudioDevice] {
        inputDevices.filter { $0.capabilities.contains(.enhancedHearing) || $0.capabilities.contains(.multiMic) }
    }

    var shouldShowEnhancedHearingSection: Bool {
        !connectedEnhancedHearingDevices.isEmpty
    }

    func selectInput(_ id: String) {
        preferredInputID = id
        VoiceCapturePreferences.preferredInputID = id
        if id != "system", let uid = UInt32(id) {
            Self.setDefaultInputDevice(uid)
        }
    }

    func selectOutput(_ id: String) {
        preferredOutputID = id
        VoiceCapturePreferences.preferredOutputID = id
        if id != "system", let uid = UInt32(id) {
            Self.setDefaultOutputDevice(uid)
        }
    }

    // MARK: - Test capture (level only — does not fake STT success)

    func runTestCapture(seconds: TimeInterval = 2.5) {
        guard !isTesting else { return }
        refreshPermission()
        guard micPermission.isUsable else {
            testMessage = "Microphone not allowed. Grant access, then test again."
            return
        }

        isTesting = true
        testMessage = "Listening…"
        testLevelDb = -96

        let engine = AVAudioEngine()
        testEngine = engine
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)

        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            guard let channel = buffer.floatChannelData?[0] else { return }
            let frameCount = Int(buffer.frameLength)
            guard frameCount > 0 else { return }
            var sum: Float = 0
            for i in 0..<frameCount {
                let s = channel[i]
                sum += s * s
            }
            let rms = sqrt(sum / Float(frameCount))
            let db = 20 * log10(max(rms, 1e-7))
            Task { @MainActor in
                self?.testLevelDb = db
            }
        }

        do {
            try engine.start()
        } catch {
            isTesting = false
            testEngine = nil
            testMessage = "Test failed: \(error.localizedDescription)"
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
            self?.finishTest()
        }
    }

    private func finishTest() {
        testEngine?.inputNode.removeTap(onBus: 0)
        testEngine?.stop()
        testEngine = nil
        isTesting = false
        lastTestAt = Date()
        if testLevelDb > -50 {
            testMessage = String(
                format: "Capture OK · peak ≈ %.0f dB · preferred input: %@",
                testLevelDb,
                displayName(forInputID: preferredInputID)
            )
        } else {
            testMessage = String(
                format: "Capture ran · very quiet (≈ %.0f dB). Check mic mute or device.",
                testLevelDb
            )
        }
    }

    func displayName(forInputID id: String) -> String {
        if id == "system" { return "System default" }
        return inputDevices.first(where: { $0.id == id })?.name ?? id
    }

    func displayName(forOutputID id: String) -> String {
        if id == "system" { return "System default" }
        return outputDevices.first(where: { $0.id == id })?.name ?? id
    }

    // MARK: - CoreAudio enumeration

    private static func enumerateInputs() -> [SelectableAudioDevice] {
        enumerateDevices(scope: kAudioDevicePropertyScopeInput)
    }

    private static func enumerateOutputs() -> [SelectableAudioDevice] {
        enumerateDevices(scope: kAudioDevicePropertyScopeOutput)
    }

    private static func enumerateDevices(scope: AudioObjectPropertyScope) -> [SelectableAudioDevice] {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var dataSize: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize
        ) == noErr else { return [] }

        let count = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var ids = [AudioDeviceID](repeating: 0, count: count)
        guard AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &ids
        ) == noErr else { return [] }

        var result: [SelectableAudioDevice] = []
        for id in ids {
            var streamAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyStreamConfiguration,
                mScope: scope,
                mElement: kAudioObjectPropertyElementMain
            )
            var streamSize: UInt32 = 0
            AudioObjectGetPropertyDataSize(id, &streamAddress, 0, nil, &streamSize)
            guard streamSize > 0 else { continue }

            guard let name = deviceName(id) else { continue }
            let caps = capabilities(forName: name, deviceID: id, scope: scope)
            let channelCount = channelCount(deviceID: id, scope: scope)
            result.append(
                SelectableAudioDevice(
                    id: String(id),
                    name: name,
                    channelCount: channelCount,
                    capabilities: caps
                )
            )
        }
        return result.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private static func deviceName(_ id: AudioDeviceID) -> String? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var size = UInt32(MemoryLayout<CFString?>.size)
        let ptr = UnsafeMutablePointer<CFString?>.allocate(capacity: 1)
        ptr.initialize(to: nil)
        defer {
            ptr.deinitialize(count: 1)
            ptr.deallocate()
        }
        guard AudioObjectGetPropertyData(id, &address, 0, nil, &size, ptr) == noErr,
              let cf = ptr.pointee else { return nil }
        return cf as String
    }

    private static func channelCount(deviceID: AudioDeviceID, scope: AudioObjectPropertyScope) -> Int {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: scope,
            mElement: kAudioObjectPropertyElementMain
        )
        var size: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &size) == noErr, size > 0 else {
            return 0
        }
        let raw = UnsafeMutableRawPointer.allocate(byteCount: Int(size), alignment: MemoryLayout<AudioBufferList>.alignment)
        defer { raw.deallocate() }
        guard AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, raw) == noErr else {
            return 0
        }
        let list = raw.assumingMemoryBound(to: AudioBufferList.self)
        let buffers = UnsafeMutableAudioBufferListPointer(list)
        var total = 0
        for buf in buffers {
            total += Int(buf.mNumberChannels)
        }
        return total
    }

    /// Capability handshake: infer only from connected device name/channels — never invent hearing-aid UI.
    private static func capabilities(
        forName name: String,
        deviceID: AudioDeviceID,
        scope: AudioObjectPropertyScope
    ) -> AudioDeviceCapability {
        var caps: AudioDeviceCapability = []
        let lower = name.lowercased()
        if lower.contains("bluetooth") || lower.contains("airpods") || lower.contains("bt ") {
            caps.insert(.bluetooth)
        }
        if lower.contains("hearing") || lower.contains("unitron") || lower.contains("phonak")
            || lower.contains("oticon") || lower.contains("widex") || lower.contains("rexton")
            || lower.contains("starkey") || lower.contains("signia") {
            caps.insert(.enhancedHearing)
        }
        let ch = channelCount(deviceID: deviceID, scope: scope)
        if ch >= 2 {
            caps.insert(.multiMic)
        }
        // Built-in stereo arrays often multi-mic for beamforming on Apple silicon
        if lower.contains("macbook") || lower.contains("imac") || lower.contains("mac studio") {
            if ch >= 2 { caps.insert(.multiMic) }
        }
        return caps
    }

    private static func setDefaultInputDevice(_ id: AudioDeviceID) {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var deviceID = id
        let size = UInt32(MemoryLayout<AudioDeviceID>.size)
        AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            size,
            &deviceID
        )
    }

    private static func setDefaultOutputDevice(_ id: AudioDeviceID) {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var deviceID = id
        let size = UInt32(MemoryLayout<AudioDeviceID>.size)
        AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            size,
            &deviceID
        )
    }
}

// MARK: - Models

struct SelectableAudioDevice: Identifiable, Hashable {
    let id: String
    let name: String
    let channelCount: Int
    let capabilities: AudioDeviceCapability

    var capabilityLabels: [String] {
        var labels: [String] = []
        if capabilities.contains(.bluetooth) { labels.append("Bluetooth") }
        if capabilities.contains(.enhancedHearing) { labels.append("Enhanced hearing") }
        if capabilities.contains(.multiMic) { labels.append("Multi-mic (\(channelCount) ch)") }
        return labels
    }
}

struct AudioDeviceCapability: OptionSet, Hashable {
    let rawValue: Int
    static let bluetooth = AudioDeviceCapability(rawValue: 1 << 0)
    static let multiMic = AudioDeviceCapability(rawValue: 1 << 1)
    static let enhancedHearing = AudioDeviceCapability(rawValue: 1 << 2)
}

enum VoiceCapturePreferences {
    private static let inputKey = "dojo.voice.preferredInputID"
    private static let outputKey = "dojo.voice.preferredOutputID"

    static var preferredInputID: String {
        get { UserDefaults.standard.string(forKey: inputKey) ?? "system" }
        set { UserDefaults.standard.set(newValue, forKey: inputKey) }
    }

    static var preferredOutputID: String {
        get { UserDefaults.standard.string(forKey: outputKey) ?? "system" }
        set { UserDefaults.standard.set(newValue, forKey: outputKey) }
    }

}

#endif

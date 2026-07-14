import Combine
import Foundation
import AVFoundation

#if os(macOS)
import CoreAudio

// MARK: - Audio Device Manager

@MainActor
public final class AudioDeviceManager: ObservableObject {
    
    @Published public private(set) var availableDevices: [AudioInputDevice] = []
    @Published public var selectedDevice: AudioInputDevice? {
        didSet {
            if let device = selectedDevice {
                saveSelectedDevice(device)
                applyDeviceSelection(device)
            }
        }
    }
    
    private var propertyListenerAdded = false
    private var deviceChangeCallback: AudioObjectPropertyListenerProc?
    private var deviceChangeContext: UnsafeMutableRawPointer?
    
    public init() {
        Task {
            await refreshDevices()
            restoreSelectedDevice()
            setupDeviceChangeListener()
        }
    }
    
    public func refreshDevices() async {
        var devices: [AudioInputDevice] = []
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var dataSize: UInt32 = 0
        let status = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize
        )
        
        guard status == noErr else { return }
        
        let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)
        
        AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &deviceIDs
        )
        
        for deviceID in deviceIDs {
            var inputAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyStreamConfiguration,
                mScope: kAudioDevicePropertyScopeInput,
                mElement: kAudioObjectPropertyElementMain
            )
            
            var inputDataSize: UInt32 = 0
            AudioObjectGetPropertyDataSize(deviceID, &inputAddress, 0, nil, &inputDataSize)
            
            guard inputDataSize > 0 else { continue }
            
            var nameAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyDeviceNameCFString,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )
            
            var nameDataSize: UInt32 = UInt32(MemoryLayout<CFString?>.size)
            let deviceNamePointer = UnsafeMutablePointer<CFString?>.allocate(capacity: 1)
            deviceNamePointer.initialize(to: nil)
            defer {
                deviceNamePointer.deinitialize(count: 1)
                deviceNamePointer.deallocate()
            }
            
            let nameStatus = AudioObjectGetPropertyData(
                deviceID,
                &nameAddress,
                0,
                nil,
                &nameDataSize,
                deviceNamePointer
            )
            
            guard nameStatus == noErr, let deviceName = deviceNamePointer.pointee else { continue }
            
            let name = deviceName as String
            let type = detectDeviceType(name: name, deviceID: deviceID)
            
            devices.append(AudioInputDevice(
                id: deviceID,
                name: name,
                type: type
            ))
        }
        
        availableDevices = devices.sorted { $0.name < $1.name }
        
        if selectedDevice == nil {
            if let x6 = devices.first(where: { $0.name.contains("X6") || $0.name.lowercased().contains("bluetooth") && $0.name.contains("X6") }) {
                selectedDevice = x6
            } else if let builtIn = devices.first(where: { $0.type == .builtIn }) {
                selectedDevice = builtIn
            } else {
                selectedDevice = devices.first
            }
        }
    }
    
    private func detectDeviceType(name: String, deviceID: AudioDeviceID) -> AudioInputDevice.DeviceType {
        let lowerName = name.lowercased()
        
        if lowerName.contains("bluetooth") || lowerName.contains("bt") || lowerName.contains("x6") {
            return .bluetooth
        }
        
        if lowerName.contains("built-in") || lowerName.contains("macbook") || lowerName.contains("imac") || lowerName.contains("mac studio") {
            return .builtIn
        }
        
        var transportAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyTransportType,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var transportType: UInt32 = 0
        var transportSize: UInt32 = UInt32(MemoryLayout<UInt32>.size)
        
        let status = AudioObjectGetPropertyData(
            deviceID,
            &transportAddress,
            0,
            nil,
            &transportSize,
            &transportType
        )
        
        if status == noErr && transportType == kAudioDeviceTransportTypeUSB {
            return .usb
        }
        
        return .unknown
    }
    
    private func applyDeviceSelection(_ device: AudioInputDevice) {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var deviceID = device.id
        let size = UInt32(MemoryLayout<AudioDeviceID>.size)
        
        AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            size,
            &deviceID
        )
    }
    
    private func saveSelectedDevice(_ device: AudioInputDevice) {
        UserDefaults.standard.set(device.id, forKey: "field.audio.selected.device.id")
        UserDefaults.standard.set(device.name, forKey: "field.audio.selected.device.name")
    }
    
    private func restoreSelectedDevice() {
        guard let savedID = UserDefaults.standard.object(forKey: "field.audio.selected.device.id") as? AudioDeviceID,
              let device = availableDevices.first(where: { $0.id == savedID }) else {
            return
        }
        selectedDevice = device
    }
    
    private func setupDeviceChangeListener() {
        guard !propertyListenerAdded else { return }
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let callback: AudioObjectPropertyListenerProc = { _, _, _, context in
            guard let context = context else { return 0 }
            let manager = Unmanaged<AudioDeviceManager>.fromOpaque(context).takeUnretainedValue()
            Task { @MainActor in
                await manager.refreshDevices()
            }
            return 0
        }
        
        let context = Unmanaged.passUnretained(self).toOpaque()
        deviceChangeCallback = callback
        deviceChangeContext = context
        
        AudioObjectAddPropertyListener(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            callback,
            context
        )
        
        propertyListenerAdded = true
    }
    
    deinit {
        if propertyListenerAdded,
           let callback = deviceChangeCallback,
           let context = deviceChangeContext {
            var propertyAddress = AudioObjectPropertyAddress(
                mSelector: kAudioHardwarePropertyDevices,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )
            AudioObjectRemovePropertyListener(
                AudioObjectID(kAudioObjectSystemObject),
                &propertyAddress,
                callback,
                context
            )
        }
    }
}

public struct AudioInputDevice: Identifiable, Hashable {
    public let id: AudioDeviceID
    public let name: String
    public let type: DeviceType
    
    public enum DeviceType: String {
        case bluetooth = "Bluetooth"
        case usb = "USB"
        case builtIn = "Built-in"
        case unknown = "Unknown"
        
        public var icon: String {
            switch self {
            case .bluetooth: return "🎧"
            case .usb: return "🔌"
            case .builtIn: return "💻"
            case .unknown: return "🎤"
            }
        }
    }
}

// MARK: - macOS Murmur Controller

@MainActor
public final class MacOSMurmurController: ObservableObject {
    
    @Published public private(set) var isCapturing = false
    @Published public private(set) var completedSessionRef: String?
    @Published public private(set) var currentRMS: Float = 0.0
    @Published public private(set) var currentRMSdB: Float = -96.0
    @Published public private(set) var lastQuality: QualityMetrics?
    
    public let deviceManager: AudioDeviceManager
    public let captureService: MurmurCaptureService
    
    private let deviceID: String
    private var metricsTask: Task<Void, Never>?
    
    public init() {
        deviceID = Self.resolveDeviceID()
        deviceManager = AudioDeviceManager()
        
        let transport = MurmurTransport(deviceID: deviceID)
        let queue = MurmurQueue(transport: transport)
        captureService = MurmurCaptureService(deviceID: deviceID, queue: queue)
        
        setupQualityMonitoring()
    }
    
    public func toggle() {
        if isCapturing {
            stop()
        } else {
            start()
        }
    }
    
    public func start() {
        guard !isCapturing else { return }
        
        do {
            try captureService.start()
            isCapturing = true
            startMetricsPolling()
        } catch {
            print("❌ Capture start failed: \(error)")
        }
    }
    
    public func stop() {
        guard isCapturing else { return }
        
        let ref = endSession()
        captureService.stop()
        isCapturing = false
        completedSessionRef = ref
        metricsTask?.cancel()
        metricsTask = nil
        
        currentRMS = 0.0
        currentRMSdB = -96.0
    }
    
    private func setupQualityMonitoring() {
        // Setup quality monitoring
    }
    
    private func startMetricsPolling() {
        metricsTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 100_000_000)
                await self?.updateMetrics()
            }
        }
    }
    
    private func updateMetrics() async {
        currentRMSdB = captureService.currentDbLevel
        await captureService.emitQualityFrame()
    }
    
    private func endSession() -> String {
        let ref = "\(deviceID):\(Int(Date().timeIntervalSince1970))"
        GeometryGateReceipt(
            sessionRef: ref,
            capability: "macos.mic.capture",
            deviceName: deviceManager.selectedDevice?.name ?? "Unknown"
        ).log()
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

public struct QualityMetrics {
    public let rmsDb: Float
    public let snrEst: Float
    public let noiseFloorDb: Float
    public let clipRate: Float
    public let vadSpeechRatio: Float
    public let timestamp: Date
    
    public var snrQuality: String {
        switch snrEst {
        case 30...: return "Excellent"
        case 20..<30: return "Good"
        case 10..<20: return "Fair"
        default: return "Poor"
        }
    }
    
    public var snrColor: String {
        switch snrEst {
        case 30...: return "#10B981"
        case 20..<30: return "#3B82F6"
        case 10..<20: return "#F59E0B"
        default: return "#EF4444"
        }
    }
}

public struct GeometryGateReceipt: Codable {
    public let sessionRef: String
    public let timestamp: Date
    public let capability: String
    public let deviceName: String
    public let sha256Hint: String
    
    public init(sessionRef: String, capability: String, deviceName: String) {
        self.sessionRef = sessionRef
        self.timestamp = Date()
        self.capability = capability
        self.deviceName = deviceName
        self.sha256Hint = String(sessionRef.prefix(8))
    }
    
    public func log() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        var log = UserDefaults.standard.array(forKey: "field.geometry.gate.log") as? [Data] ?? []
        log.append(data)
        if log.count > 50 { log.removeFirst(log.count - 50) }
        UserDefaults.standard.set(log, forKey: "field.geometry.gate.log")
        
        print("✅ G6 Gate Receipt logged: \(capability) | Device: \(deviceName) | Ref: \(sha256Hint)")
    }
    
    public static func fetchAll() -> [GeometryGateReceipt] {
        guard let log = UserDefaults.standard.array(forKey: "field.geometry.gate.log") as? [Data] else {
            return []
        }
        return log.compactMap { try? JSONDecoder().decode(GeometryGateReceipt.self, from: $0) }
    }
}

#endif

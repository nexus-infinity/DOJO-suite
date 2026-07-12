import Foundation
import Network
import Combine
#if os(macOS)
import CoreAudio
#endif
#if os(iOS) || os(watchOS)
import AVFoundation
#endif

/// Monitors the physical environment (Network, Audio Routes) to feed DOJOFieldCoordinator's profile switching.
@MainActor
public final class HALEnvironmentMonitor: ObservableObject {
    @Published public private(set) var isBluetoothAudioConnected: Bool = false
    @Published public private(set) var isWifiConnected: Bool = false

    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "HALNetworkMonitor")
    private var cancellables = Set<AnyCancellable>()
    #if os(macOS)
    private var outputDeviceListenerAdded = false
    private var outputDeviceChangeCallback: AudioObjectPropertyListenerProc?
    private var outputDeviceChangeContext: UnsafeMutableRawPointer?
    #endif

    public init() {
        startMonitoring()
    }

    private func startMonitoring() {
        // 1. Network Monitoring (Wi-Fi = Home Field proxy)
        pathMonitor.pathUpdateHandler = { [weak self] path in
            let isWifi = path.usesInterfaceType(.wifi)
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if self.isWifiConnected != isWifi {
                    self.isWifiConnected = isWifi
                }
            }
        }
        pathMonitor.start(queue: monitorQueue)

        // 2. Audio Route Monitoring (Bluetooth = Intimate proxy)
        #if os(macOS)
        checkAudioRoute()
        setupAudioRouteListener()
        #endif
        #if os(iOS)
        NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.checkAudioRoute()
                }
            }
            .store(in: &cancellables)
        
        checkAudioRoute() // Initial check
        #endif
    }

    #if os(macOS)
    private func checkAudioRoute() {
        let isBT = defaultOutputDeviceIsBluetooth()
        if self.isBluetoothAudioConnected != isBT {
            self.isBluetoothAudioConnected = isBT
        }
    }

    private func defaultOutputDeviceIsBluetooth() -> Bool {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var deviceID: AudioDeviceID = 0
        var deviceSize: UInt32 = UInt32(MemoryLayout<AudioDeviceID>.size)
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &deviceSize,
            &deviceID
        )

        guard status == noErr, deviceID != 0 else { return false }

        let lowerName = audioDeviceName(deviceID)?.lowercased() ?? ""
        if lowerName.contains("bluetooth") || lowerName.contains("airpods") || lowerName.contains("x6") {
            return true
        }

        var transportAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyTransportType,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var transportType: UInt32 = 0
        var transportSize: UInt32 = UInt32(MemoryLayout<UInt32>.size)
        let transportStatus = AudioObjectGetPropertyData(
            deviceID,
            &transportAddress,
            0,
            nil,
            &transportSize,
            &transportType
        )

        guard transportStatus == noErr else { return false }
        return transportType == kAudioDeviceTransportTypeBluetooth ||
            transportType == kAudioDeviceTransportTypeBluetoothLE
    }

    private func audioDeviceName(_ deviceID: AudioDeviceID) -> String? {
        var nameAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var nameSize: UInt32 = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
        var unmanagedDeviceName: Unmanaged<CFString>?
        let status = AudioObjectGetPropertyData(
            deviceID,
            &nameAddress,
            0,
            nil,
            &nameSize,
            &unmanagedDeviceName
        )

        guard status == noErr, let unmanagedDeviceName else { return nil }
        let deviceName = unmanagedDeviceName.takeRetainedValue()
        return deviceName as String
    }

    private func setupAudioRouteListener() {
        guard !outputDeviceListenerAdded else { return }

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let callback: AudioObjectPropertyListenerProc = { _, _, _, context in
            guard let context else { return 0 }
            let monitor = Unmanaged<HALEnvironmentMonitor>.fromOpaque(context).takeUnretainedValue()
            Task { @MainActor in
                monitor.checkAudioRoute()
            }
            return 0
        }

        let context = Unmanaged.passUnretained(self).toOpaque()
        outputDeviceChangeCallback = callback
        outputDeviceChangeContext = context

        AudioObjectAddPropertyListener(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            callback,
            context
        )

        outputDeviceListenerAdded = true
    }
    #endif

    #if os(iOS)
    private func checkAudioRoute() {
        let route = AVAudioSession.sharedInstance().currentRoute
        let isBT = route.outputs.contains {
            $0.portType == .bluetoothA2DP ||
            $0.portType == .bluetoothHFP ||
            $0.portType == .bluetoothLE
        }
        if self.isBluetoothAudioConnected != isBT {
            self.isBluetoothAudioConnected = isBT
        }
    }
    #endif

    deinit {
        pathMonitor.cancel()
        #if os(macOS)
        if outputDeviceListenerAdded,
           let callback = outputDeviceChangeCallback,
           let context = outputDeviceChangeContext {
            var propertyAddress = AudioObjectPropertyAddress(
                mSelector: kAudioHardwarePropertyDefaultOutputDevice,
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
        #endif
    }
}

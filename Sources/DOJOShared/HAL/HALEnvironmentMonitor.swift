import Foundation
import Network
import Combine
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
}

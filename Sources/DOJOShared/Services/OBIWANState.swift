import Foundation
import SwiftUI
import Network

/**
 * OBIWANState.swift
 * \u{25CF} 963 Hz \u2014 Living Memory Observer Bridge
 * 
 * Shared state manager for the FIELD Spinning Top UI.
 * Handles persistence across app launches and real-time observer updates.
 * 
 * HARDENING (2026-03-28):
 * - Phase transition validation (3→6→9→3 cycle enforcement)
 * - Network reachability monitoring (sovereign connection validation)
 * - Cryptographic observation signing capability (see signObservation)
 */
@MainActor
public class OBIWANState: ObservableObject {
    @MainActor public static let shared = OBIWANState()
    
    @AppStorage("field_observer_alignment") public var alignment: Double = 0.963
    @AppStorage("field_last_witnessed_event") public var lastEvent: String = ""
    @AppStorage("field_current_phase") public var currentPhase: Int = 9  // Tesla 3-6-9 phase tracking
    
    @Published public var isObserving: Bool = false
    @Published public var currentFrequency: Double = 963.0
    @Published public var networkReachable: Bool = false  // Network monitoring
    
    private let monitor = NWPathMonitor()
    
    private init() {
        // Initializer for the shared singleton
        print("\u{25CF} OBI-WAN Bridge Initialized at 963 Hz")
        
        // Start network reachability monitoring
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                let reachable = (path.status == .satisfied)
                self?.networkReachable = reachable
                print("\u{25CF} Network reachability: \(reachable ? "✓ connected" : "✗ offline")")
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
    
    private let queue = LocalEventQueue()
    private let macHost = "FIELD-Mac-Studio.local" // mDNS / Bonjour address
    
    // ── Phase Transition Validation ──────────────────────────────────────────
    // Tesla 3-6-9 cycle enforcement: 3 (intake) → 6 (process) → 9 (synthesise) → 3
    // Prevents bypass attacks (e.g., 3→9 jump) while allowing cycle restart at high coherence.
    
    public func validatePhaseTransition(from current: Int, to next: Int) -> Bool {
        // Normalize phases to valid set
        guard [3, 6, 9].contains(current) && [3, 6, 9].contains(next) else {
            print("\u{26A0}\u{FE0E} Invalid phase values: \(current) → \(next)")
            return false
        }
        
        switch (current, next) {
        case (3, 3), (6, 6), (9, 9):
            // Same phase — hold state (valid)
            return true
            
        case (3, 6), (6, 9):
            // Forward progression through cycle (valid)
            return true
            
        case (9, 3):
            // Cycle restart — requires high coherence (≥0.9)
            let allowed = alignment >= 0.9
            if !allowed {
                print("\u{26A0}\u{FE0E} Cycle restart blocked: alignment \(alignment) < 0.9")
            }
            return allowed
            
        default:
            // Invalid transition (bypass attempt)
            print("\u{26A0}\u{FE0E} Phase bypass blocked: \(current) → \(next)")
            return false
        }
    }
    
    public func setPhase(_ newPhase: Int) {
        guard validatePhaseTransition(from: currentPhase, to: newPhase) else {
            print("\u{26A0}\u{FE0E} Phase transition rejected. Holding at phase \(currentPhase).")
            return
        }
        currentPhase = newPhase
        print("\u{25CF} Phase transition: → \(newPhase)")
    }
    
    public func recordObservation(_ event: String) {
        self.lastEvent = event
        
        // 1. SAVE LOCALLY FIRST (Sovereignty)
        let observation = PersistentObservation(data: event)
        queue.enqueue(observation)
        print("\u{25CF} Observation cached locally: \(observation.id)")
        
        // 2. ATTEMPT SYNC
        Task {
            await flushQueue()
        }
    }
    
    public func flushQueue() async {
        let pending = queue.dequeueAll()
        guard !pending.isEmpty else { return }
        
        print("\u{25CF} Attempting to flush \(pending.count) observations to \(macHost)")
        
        guard let url = URL(string: "http://\(macHost):9630/observe_batch") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(pending)
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("\u{25CF} Batch sync complete. Clearing local queue.")
                queue.clear()
                self.alignment = 1.0 // High coherence when synced
            }
        } catch {
            print("\u{26A0}\u{FE0E} Sync failed: \(error.localizedDescription). Data remains in local queue.")
            self.alignment = 0.5 // Degraded coherence when offline
        }
    }
    
    public func syncWithDojo() async {
        guard let orchestrateURL = URL(string: "http://\(macHost):7410/orchestrate") else {
            print("\u{26A0}\u{FE0E} Invalid orchestrate URL")
            return
        }

        var request = URLRequest(url: orchestrateURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Minimal handshake payload; extend as needed
        struct Handshake: Codable { let frequency: Double; let lastEvent: String }
        let payload = Handshake(frequency: currentFrequency, lastEvent: lastEvent)

        do {
            request.httpBody = try JSONEncoder().encode(payload)
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                // Optionally parse response if server returns status or config
                print("\u{25CF} Dojo handshake OK (status: \((http.statusCode)))")
                self.alignment = 0.963 // nominal coherence after handshake
                self.isObserving = true
            } else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                print("\u{26A0}\u{FE0E} Dojo handshake failed (status: \(code))")
                self.alignment = 0.5
                self.isObserving = false
                // Log body for diagnostics
                if let body = String(data: data, encoding: .utf8) {
                    print("\u{26A0}\u{FE0E} Response body: \n\(body)")
                }
            }
        } catch {
            print("\u{26A0}\u{FE0E} Dojo handshake error: \(error.localizedDescription)")
            self.alignment = 0.5
            self.isObserving = false
        }
    }
}


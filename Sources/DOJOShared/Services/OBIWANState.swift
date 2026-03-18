import Foundation
import SwiftUI

/**
 * OBIWANState.swift
 * \u{25CF} 963 Hz \u2014 Living Memory Observer Bridge
 * 
 * Shared state manager for the FIELD Spinning Top UI.
 * Handles persistence across app launches and real-time observer updates.
 */
@MainActor
public class OBIWANState: ObservableObject {
    @MainActor public static let shared = OBIWANState()
    
    @AppStorage("field_observer_alignment") public var alignment: Double = 0.963
    @AppStorage("field_last_witnessed_event") public var lastEvent: String = ""
    
    @Published public var isObserving: Bool = false
    @Published public var currentFrequency: Double = 963.0
    
    private init() {
        // Initializer for the shared singleton
        print("\u{25CF} OBI-WAN Bridge Initialized at 963 Hz")
    }
    
    private let queue = LocalEventQueue()
    private let macHost = "FIELD-Mac-Studio.local" // mDNS / Bonjour address
    
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


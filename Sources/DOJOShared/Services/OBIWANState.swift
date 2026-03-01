import Foundation
import SwiftUI

/**
 * OBIWANState.swift
 * \u25cf 963 Hz \u2014 Living Memory Observer Bridge
 * 
 * Shared state manager for the FIELD Spinning Top UI.
 * Handles persistence across app launches and real-time observer updates.
 */
@MainActor
public class OBIWANState: ObservableObject {
    public static let shared = OBIWANState()
    
    @AppStorage("field_observer_alignment") public var alignment: Double = 0.963
    @AppStorage("field_last_witnessed_event") public var lastEvent: String = ""
    
    @Published public var isObserving: Bool = false
    @Published public var currentFrequency: Double = 963.0
    
    private init() {
        // Initializer for the shared singleton
        print("\u25cf OBI-WAN Bridge Initialized at 963 Hz")
    }
    
    private let queue = LocalEventQueue()
    private let macHost = "FIELD-Mac-Studio.local" // mDNS / Bonjour address
    
    public func recordObservation(_ event: String) {
        self.lastEvent = event
        
        // 1. SAVE LOCALLY FIRST (Sovereignty)
        let observation = PersistentObservation(data: event)
        queue.enqueue(observation)
        print("\u25cf Observation cached locally: \(observation.id)")
        
        // 2. ATTEMPT SYNC
        Task {
            await flushQueue()
        }
    }
    
    public func flushQueue() async {
        let pending = queue.dequeueAll()
        guard !pending.isEmpty else { return }
        
        print("\u25cf Attempting to flush \(pending.count) observations to \(macHost)")
        
        guard let url = URL(string: "http://\(macHost):9630/observe_batch") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(pending)
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("\u25cf Batch sync complete. Clearing local queue.")
                queue.clear()
                self.alignment = 1.0 // High coherence when synced
            }
        } catch {
            print("\u26a0\ufe0e Sync failed: \(error.localizedDescription). Data remains in local queue.")
            self.alignment = 0.5 // Degraded coherence when offline
        }
    }
    
    public func syncWithDojo() async {
        guard let url = URL(string: "http://\(macHost):7410/orchestrate") else { return }
        // ... Bilateral Handshake logic continues ...
    }
}

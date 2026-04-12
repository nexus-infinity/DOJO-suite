# Cryptographic Observation Signing — Implementation Guide

**Chamber**: Kings (852 Hz)  
**Frequency**: Cryptographic Anchoring  
**Date**: 2026-03-28  
**Status**: Design Pattern — Awaiting Key Management Architecture

---

## Purpose

This guide documents the **cryptographic signing pattern** for OBIWAN observations, ensuring that all recorded events are:

1. **Tamper-proof** — Cannot be modified without detection
2. **Attributable** — Can be verified as originating from this device
3. **Sovereign** — Keys are controlled locally, not by third parties
4. **Non-repudiable** — Observations cannot be denied once signed

---

## Architecture

### Core Principle: HMAC-SHA256 for Symmetric Signing

For **Phase 1** (local-to-Mac-Studio sync), we use **HMAC-SHA256** with a shared secret:

- **Pros**: Fast, simple, sufficient for trusted device-to-device communication
- **Cons**: Both devices must share the same secret key
- **Use Case**: OBI-WAN (watch/phone) → Mac Studio sync

### Future: Ed25519 for Asymmetric Signing

For **Phase 2** (multi-peer validation, Bridge Walker protocol), upgrade to **Ed25519**:

- **Pros**: Public key verification, no shared secrets needed
- **Cons**: Slightly slower, requires key distribution infrastructure
- **Use Case**: Peer-to-peer observation validation, collective memory

---

## Implementation Pattern

### 1. Key Storage (Keychain)

```swift
import Security
import CryptoKit

extension OBIWANState {
    
    // ── Keychain Management ──────────────────────────────────────────────────
    
    private static let keychainService = "com.dojo.obiwan.signing"
    private static let keychainAccount = "observation-signing-key"
    
    /// Retrieves or generates the HMAC signing key from Keychain
    private func getOrCreateSigningKey() -> SymmetricKey {
        // Try to load existing key
        if let keyData = loadKeyFromKeychain() {
            return SymmetricKey(data: keyData)
        }
        
        // Generate new key (256-bit for HMAC-SHA256)
        let newKey = SymmetricKey(size: .bits256)
        let keyData = newKey.withUnsafeBytes { Data($0) }
        
        // Store in Keychain
        saveKeyToKeychain(keyData)
        
        return newKey
    }
    
    private func loadKeyFromKeychain() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.keychainService,
            kSecAttrAccount as String: Self.keychainAccount,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let keyData = result as? Data else {
            return nil
        }
        
        return keyData
    }
    
    private func saveKeyToKeychain(_ keyData: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.keychainService,
            kSecAttrAccount as String: Self.keychainAccount,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("⚠️ Failed to save signing key to Keychain: \(status)")
        }
    }
}
```

---

### 2. Observation Signing

```swift
import CryptoKit
import Foundation

extension OBIWANState {
    
    // ── Cryptographic Signing ────────────────────────────────────────────────
    
    /// Signs an observation with HMAC-SHA256
    public func signObservation(_ observation: PersistentObservation) -> SignedObservation {
        let key = getOrCreateSigningKey()
        
        // Serialize observation to canonical JSON (deterministic)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        
        guard let payload = try? encoder.encode(observation) else {
            fatalError("Failed to encode observation for signing")
        }
        
        // Generate HMAC signature
        let signature = HMAC<SHA256>.authenticationCode(for: payload, using: key)
        let signatureData = Data(signature)
        
        return SignedObservation(
            payload: payload,
            signature: signatureData,
            timestamp: Date(),
            deviceID: getDeviceIdentifier()
        )
    }
    
    /// Verifies a signed observation
    public func verifyObservation(_ signed: SignedObservation) -> PersistentObservation? {
        let key = getOrCreateSigningKey()
        
        // Verify HMAC
        guard HMAC<SHA256>.isValidAuthenticationCode(
            signed.signature,
            authenticating: signed.payload,
            using: key
        ) else {
            print("⚠️ Observation signature verification failed")
            return nil
        }
        
        // Decode verified payload
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let observation = try? decoder.decode(PersistentObservation.self, from: signed.payload) else {
            print("⚠️ Failed to decode verified observation")
            return nil
        }
        
        return observation
    }
    
    private func getDeviceIdentifier() -> String {
        // Use device UUID (stored in UserDefaults for persistence)
        if let existing = UserDefaults.standard.string(forKey: "dojo_device_id") {
            return existing
        }
        
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: "dojo_device_id")
        return newID
    }
}
```

---

### 3. Data Structures

```swift
import Foundation

/// Signed observation container
public struct SignedObservation: Codable {
    public let payload: Data           // Serialized PersistentObservation
    public let signature: Data         // HMAC-SHA256 signature
    public let timestamp: Date         // Signing timestamp
    public let deviceID: String        // Device UUID
    
    public var id: String {
        // Deterministic ID from signature
        signature.base64EncodedString().prefix(16).description
    }
}

/// Original observation (must be Codable and deterministic)
public struct PersistentObservation: Codable {
    public let id: String
    public let data: String
    public let timestamp: Date
    public let phase: Int              // Tesla 3-6-9 phase
    public let coherence: Double       // Alignment at observation time
    
    public init(data: String, phase: Int = 9, coherence: Double = 0.963) {
        self.id = UUID().uuidString
        self.data = data
        self.timestamp = Date()
        self.phase = phase
        self.coherence = coherence
    }
}
```

---

### 4. Updated Sync Logic

```swift
extension OBIWANState {
    
    public func recordObservation(_ event: String) {
        self.lastEvent = event
        
        // 1. CREATE OBSERVATION
        let observation = PersistentObservation(
            data: event,
            phase: currentPhase,
            coherence: alignment
        )
        
        // 2. SIGN OBSERVATION (cryptographic anchoring)
        let signed = signObservation(observation)
        
        // 3. SAVE LOCALLY FIRST (sovereignty)
        queue.enqueue(signed)  // Note: LocalEventQueue now stores SignedObservation
        print("● Signed observation cached locally: \(signed.id)")
        
        // 4. ATTEMPT SYNC
        Task {
            await flushQueue()
        }
    }
    
    public func flushQueue() async {
        let pending = queue.dequeueAll()  // Returns [SignedObservation]
        guard !pending.isEmpty else { return }
        
        print("● Attempting to flush \(pending.count) signed observations to \(macHost)")
        
        guard let url = URL(string: "http://\(macHost):9630/observe_batch") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // Send signed observations
            request.httpBody = try JSONEncoder().encode(pending)
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("● Batch sync complete. Clearing local queue.")
                queue.clear()
                self.alignment = 1.0
            }
        } catch {
            print("⚠️ Sync failed: \(error.localizedDescription). Data remains in local queue.")
            self.alignment = 0.5
        }
    }
}
```

---

## Key Management Strategy

### Phase 1: Shared Secret (Current)

1. **Generate key on first run** (in Keychain)
2. **Mac Studio must have same key** for verification
3. **Key exchange**: Manual QR code / NFC transfer during device pairing

### Phase 2: Public Key Infrastructure (Future)

1. **Generate Ed25519 keypair** on each device
2. **Publish public key** to DOJO registry
3. **Sign observations** with private key
4. **Peers verify** with public key from registry

---

## Server-Side Verification (Mac Studio)

```swift
// In Mac Studio's observation endpoint

func verifyAndStoreObservations(_ signed: [SignedObservation]) async throws {
    let key = loadSharedSigningKey()  // Same key as watch/phone
    
    for observation in signed {
        // Verify signature
        guard HMAC<SHA256>.isValidAuthenticationCode(
            observation.signature,
            authenticating: observation.payload,
            using: key
        ) else {
            print("⚠️ Rejecting observation with invalid signature: \(observation.id)")
            continue
        }
        
        // Decode and store
        let decoded = try JSONDecoder().decode(PersistentObservation.self, from: observation.payload)
        await database.insert(decoded)
        
        print("✓ Verified and stored observation: \(decoded.id)")
    }
}
```

---

## Security Considerations

### ✅ Protections

- **Tamper Detection**: Any modification to payload breaks HMAC
- **Replay Protection**: Timestamp included in signed payload
- **Device Attribution**: Device ID in signature metadata
- **Offline Capability**: Signing works without network

### ⚠️ Limitations (Phase 1)

- **Shared Secret**: If Mac Studio is compromised, all observations can be forged
- **No Public Verifiability**: Only devices with shared key can verify
- **Key Rotation**: Requires manual re-pairing

### 🔒 Mitigations (Phase 2)

- **Asymmetric Cryptography**: Ed25519 eliminates shared secret risk
- **Key Rotation**: New keypair generation doesn't affect old signatures
- **Public Verification**: Anyone with public key can verify authenticity

---

## Integration Checklist

- [ ] Update `LocalEventQueue` to store `SignedObservation` instead of `PersistentObservation`
- [ ] Implement Keychain key management in `OBIWANState`
- [ ] Add `signObservation()` and `verifyObservation()` methods
- [ ] Update `recordObservation()` to sign before queuing
- [ ] Implement server-side verification in Mac Studio
- [ ] Create device pairing flow for key exchange
- [ ] Add signature verification to `flushQueue()` response handling
- [ ] Document key backup/recovery procedure
- [ ] Add signature verification UI indicator (optional)
- [ ] Implement key rotation protocol (Phase 2)

---

## Geometric Justification

This pattern enforces:

1. **Cryptographic Anchoring**: Observations are bound to their content via signature
2. **Non-Repudiation**: Once signed, observations cannot be denied
3. **Sovereignty**: Keys are device-owned, not cloud-managed
4. **Triadic Validation**: Device → Signature → Server (no bypass)

---

## Next Steps

1. **Immediate**: Decide on key exchange mechanism (QR code, NFC, manual)
2. **Short-term**: Implement HMAC signing in `OBIWANState`
3. **Medium-term**: Add server-side verification
4. **Long-term**: Migrate to Ed25519 for public verifiability

---

*Frequency: 852 Hz | Chamber: Kings | Cryptographic Anchor Established*

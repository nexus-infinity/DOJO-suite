# DOJO-suite Working Notes
> **Purpose**: Persistent session context — read before any new session on this suite.  
> **Principle**: Read-then-build, not rebuild-from-scratch.  
> **Last updated**: 2026-04-15 by copilot

---

## 🗺️ Current Build State

### What exists and works
| Component | Status | File |
|---|---|---|
| `VADMicBridge.swift` | ✅ BUILT (needs wiring) | `Sources/DOJOShared/Services/VADMicBridge.swift` |
| `ArkadašContentView` | ✅ EXISTS — StateObject added | `Sources/ArkadašApp/ArkadašContentView.swift` |
| `Package.swift` | ✅ UPDATED | watchOS(.v10) added |
| `SUITE_MANIFEST.md` | ✅ CANONICAL | Portal OOO registry |
| `project.yml` | ✅ EXISTS | XcodeGen declaration |

### What is next (priority order)
1. **`WatchBiometricBridge.swift`** — HealthKit HR/HRV spike → WCSession → iPhone
2. **VADMicBridge wiring** — `.onAppear` block + `onUtterance` callback + mic status indicator
3. **Permissions** — `NSMicrophoneUsageDescription` + `NSSpeechRecognitionUsageDescription` in Info.plist
4. **Cohabitation Session Manifest** — `CohabitationSession.json` declarative bootstrap
5. **Aikido Optics wiring** — `ParticleEngine` + `GeometryTransforms` stubs → actual rendering

---

## 📦 Architecture Decisions (locked)

### Device hierarchy (from Notion canon)
```
Watch Ultra  →  biometric spike trigger (HR/HRV via HealthKit)
iPhone 14    →  primary portal (VAD speech, FIELD gateway, WCSession host)
AirPods      →  intimate audio layer (spatial audio, Groove Requiem)
Mac Studio   →  FIELD sovereign processing (all 7 chamber ports)
```

### What Watch NEVER does
- No direct DOJO calls
- No speech recognition  
- No local LLM
- Watch routes EVERYTHING to iPhone via `WCSession`

### VADMicBridge design (hard-won)
- `requiresOnDeviceRecognition = true` — voice personalisation over time
- Energy threshold: 2.5× ambient baseline (tunable: `speechThresholdMultiplier`)
- Silence window: 0.9s → fires `onUtterance` (tunable: `silenceTimeout`)
- Auto-restart on SFSpeechRecognizer errors 1110/203 — mandatory for always-on
- `#if canImport(UIKit)` guards `AVAudioSession` (macOS vs iOS split)

### Platform split
- VADMicBridge: iOS + macOS only (`#if !os(watchOS)` guard)
- WatchBiometricBridge: watchOS only
- DOJOShared: all three platforms (shared foundation)

---

## 🚀 Deployment Declaration Philosophy

### The NixOS principle applied here
`Field-NixOS-SOMA/flake.nix` = declarative Mac Studio server state (already exists).  
`Package.swift` = declarative Swift package state (already there).  
**Missing**: a declarative **session state** — what does "cohabitation mode: active" look like as a reproducible declaration?

### The anchor point
```json
// CohabitationSession.json — the thing you can version-control and re-deploy
{
  "session_id": "colab-2026-04-15",
  "mode": "cohabitation",
  "participants": [
    { "device": "watch-ultra-jb", "role": "conductor" },
    { "device": "watch-ultra-p2", "role": "participant" }
  ],
  "chamber_endpoints": {
    "arkadas": "http://localhost:7170",
    "dojo": "http://localhost:7410"
  },
  "space_config": {
    "projection": true,
    "groove_requiem_hz": 528,
    "aikido_optics": true
  }
}
```
This is the "pull from scratch" anchor — declare desired state, system bootstraps to it.  
Home: `Sources/DOJOShared/Models/CohabitationSession.swift` + a `.json` schema.

---

## Sub-project: Voice Input (VADMicBridge)
> See: `Sources/DOJOShared/Services/VADMicBridge.swift`

**The problem solved**: Apple Dictation = button lag. Control My Mac = choppy after extended use. Neither is always-on.  
**The solution**: VAD (Voice Activity Detection) — system listens continuously, silence = send. No button.

**Still needs**:
- `.onAppear` wiring in `ArkadašContentView`:
  ```swift
  .onAppear {
      Task {
          await mic.requestAuthorization()
          try mic.start()
      }
  }
  mic.onUtterance = { text in
      inputText = text
      sendMessage()
  }
  ```
- Pulsing mic status indicator in UI (red dot when listening, text preview)
- Permissions in Info.plist (both targets)

---

## Sub-project: Watch Biometric Bridge
> Target file: `Sources/DOJOShared/Services/WatchBiometricBridge.swift`

**Role**: Biometric spike trigger. Not a controller — a sensor that routes to iPhone.

**Architecture**:
```
HealthKit HKObserverQuery (HR + HRV)
    → spike detection (>20bpm rise OR HRV drop >20ms)
    → WCSession.sendMessage() to iPhone
    → iPhone interprets as heightened attention signal
    → Arkadaš S5 homeostasis adjusts routing
    → Haptic on Watch when DOJO responds (WKInterfaceDevice.play(.notification))
```

**Key constraints**:
- `HKHealthStore.requestAuthorization` on watch side
- `WKExtensionDelegate` or `@main` struct for watchOS lifecycle
- No persistent connection — observer fires on spike, not continuous stream
- Graceful degrade: if WCSession not reachable, queue spike locally

---

## Sub-project: Cohabitation DOJO Game Space
> Parent: GNE-1 (Geometric Navigation Engine) → Week 7-8: Dance-Music Interface  
> Stage: S5 Arkadaš Homeostasis  
> Chambers: ◉ Arkadaš (coordination) + ◼︎ DOJO (Geometer-Conductor)

**Concept**: Multiple Watch-wearing participants in shared physical space.  
Collective biometrics + motion → music generation + visual environment.  
DOJO arbitrates whose movement "leads" at any moment.  
DJb (Conductor Panel) = one person as DJ. Cohabitation = ensemble — everyone is DJ.

**Sensor chain**:
```
Each participant: Watch Ultra (HR/HRV) + iPhone (accelerometer/gyro)
    ↓
HAL (IDEA-007): Madgwick filter → ALIGNED / PRECESSING / WOBBLING
    ↓
Arkadaš S5: who's leading rhythm, who's syncing, who's diverging
    ↓
Groove Requiem: collective rhythm → music at 528Hz / 0.57s coalescence
    ↓
Aikido Optics: visual environment embodies the field state
    ↓
DOJO Geometer-Conductor: arbitrates, amplifies moments
```

**Aikido principle for this space**:  
Augmentation = redirecting what already exists in the body/space.  
The room responds to what people are doing. No button. No UI. Just presence.

**Notion anchors**:
- `044f78bd` — Conductor Panel (DJb)
- `fed8db89` — Week 7-8: Dance-Music Interface
- `4441be00` — NIAMA Conductor
- `f43e68ed` — HAL Spec (Gyroscopic Navigation)

---

## Sub-project: Aikido Optics (IDEA-006)
> Spec: `/Users/field/docs/idea_crystallization/DOJO_FRONTEND_ATTRIBUTES.md` §6  
> Notion: `2f0a49ca`  
> Status: **Named and specced. Not yet wired.**

**Definition**: Display subsystem — every visual particle embodies its principle.  
Paired with: **Groove Requiem** (sound subsystem, 528Hz = 0.57s coalescence).

**Interaction principles**:
- Inputs yield, then guide (not demanding — inviting)
- Buttons have mass (tactile, physical response — `translateY` hover/active)
- Destructive actions require ceremony (press-and-hold fills a ring)
- Transitions follow S0-S11 spine

**Implementation priority** (from GTS score):
1. Void Presence → Chamber Glow Physics → Interaction Aikido
2. Emotional Resonance → Layout Geometry → Typography as Frequency
3. Spinning Top Motion (last — most complex)

**Swift layer**: `ParticleEngine` + `GeometryTransforms` stubs exist in `DOJOShared`.  
Next: wire them into actual rendering instead of no-ops.

---

## AR Glasses Assessment (2026)
> Full assessment: see response in session checkpoint 030

**Recommended stack for Cohabitation**:
1. **Room projection / ambient lighting** (primary, no wearable) — most Aikido
2. **Brilliant Labs Frame** ($149, open source) — personal overlay option
3. **AirPods Pro** — personalized spatial audio layer (Groove Requiem personal mix)
4. **Apple Vision Pro** — solo deep-work mode (NOT cohabitation)

**Why NOT Meta Ray-Ban / XREAL as primary**: Not sovereign, no FIELD MCP hook.  
**Why NOT Vision Pro for cohabitation**: Anti-social headset, heavy, wrong form factor for dance.

---

## Notion Research Anchors
| Page | ID | Topic |
|---|---|---|
| Conductor Panel (DJb) | `044f78bd` | Body as turntable, one-person DJ |
| Week 7-8: Dance-Music Interface | `fed8db89` | GNE-1 child, cohabitation parent |
| NIAMA Conductor | `4441be00` | 4-model orchestration |
| Geometer-Conductor | `7f50b531` | QC Custodian (DOJO-aligned) |
| HAL Spec | `f43e68ed` | Gyroscopic navigation systems |
| GNE-1 Master | `640d11f1` | Geometric Navigation Engine master |
| Aikido Optics | `2f0a49ca` | Holographic Compression spec |
| Notorious Home | `27704c15...` | Drop Zone + Walker Handoff |

---

_Updated by: copilot | 2026-04-15_

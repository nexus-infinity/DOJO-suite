# G6 Hardware Gate — System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      DOJO Suite — G6 Hardware Gate                      │
│                    macOS Audio Capture System (v0)                      │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│  HARDWARE LAYER                                                         │
└─────────────────────────────────────────────────────────────────────────┘

    🎧 X6 Bluetooth Headphones     💻 MacBook Pro Mic     🔌 USB Interface
           ↓                              ↓                      ↓
    ┌──────────────────────────────────────────────────────────────────┐
    │            macOS Core Audio System (System Level)                │
    │  • kAudioHardwarePropertyDevices                                 │
    │  • kAudioDevicePropertyTransportType                             │
    │  • Hot-plug detection via property listeners                     │
    └──────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│  DEVICE MANAGEMENT LAYER                                                │
└─────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────┐
    │  AudioDeviceManager (@MainActor ObservableObject)               │
    │  ┌───────────────────────────────────────────────────────────┐  │
    │  │ @Published availableDevices: [AudioInputDevice]           │  │
    │  │ @Published selectedDevice: AudioInputDevice?              │  │
    │  └───────────────────────────────────────────────────────────┘  │
    │                                                                  │
    │  Capabilities:                                                   │
    │  • Device enumeration (Bluetooth/USB/Built-in)                   │
    │  • Type detection with icons (🎧 🔌 💻 🎤)                      │
    │  • Selection persistence (UserDefaults)                          │
    │  • Hot-plug event handling                                       │
    └─────────────────────────────────────────────────────────────────┘
                              ↓

┌─────────────────────────────────────────────────────────────────────────┐
│  CAPTURE PIPELINE LAYER                                                 │
└─────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────┐
    │  MacOSMurmurController (@MainActor ObservableObject)            │
    │  ┌───────────────────────────────────────────────────────────┐  │
    │  │ @Published isCapturing: Bool                              │  │
    │  │ @Published currentRMS: Float                              │  │
    │  │ @Published currentRMSdB: Float                            │  │
    │  │ @Published lastQuality: QualityMetrics?                   │  │
    │  │ @Published completedSessionRef: String?                   │  │
    │  └───────────────────────────────────────────────────────────┘  │
    │                                                                  │
    │  owns: AudioDeviceManager, MurmurCaptureService                  │
    └─────────────────────────────────────────────────────────────────┘
                              ↓
    ┌─────────────────────────────────────────────────────────────────┐
    │  MurmurCaptureService (Shared iOS/macOS)                        │
    │  ┌───────────────────────────────────────────────────────────┐  │
    │  │ AVAudioEngine (native rate → 16kHz conversion)            │  │
    │  │ ├─ inputNode.installTap(onBus: 0)                         │  │
    │  │ ├─ AVAudioConverter (Float32 → PCM16LE)                   │  │
    │  │ └─ Buffer accumulation (100ms chunks + 1s quality frames) │  │
    │  └───────────────────────────────────────────────────────────┘  │
    │                                                                  │
    │  Emits:                                                          │
    │  • Audio chunks (100ms, 1600 samples @ 16kHz)                    │
    │  • Quality frames (1s, SNR/RMS/VAD/Clip/Noise)                   │
    └─────────────────────────────────────────────────────────────────┘
                              ↓
    ┌─────────────────────────────────────────────────────────────────┐
    │  MurmurQueue (Actor-based packet queue)                         │
    │  • Queues: .audioChunk, .qualityFrame, .heartbeat               │
    │  • Batching + priority handling                                  │
    └─────────────────────────────────────────────────────────────────┘
                              ↓
    ┌─────────────────────────────────────────────────────────────────┐
    │  MurmurTransport (WebSocket to backend)                         │
    │  • Schema: FIELD_MURMUR_PACKET_V0                                │
    │  • Destination: SpinningTop MCP (port 7410)                      │
    └─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│  USER INTERFACE LAYER                                                   │
└─────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────┐
    │  DOJOAudioCaptureView (Main Window)                             │
    │  ┌───────────────────────────────────────────────────────────┐  │
    │  │ ┌─────────────────────────────────────────────────────┐   │  │
    │  │ │ Device Selector (Top Bar)                           │   │  │
    │  │ │ INPUT DEVICE: [🎧 X6 Bluetooth Headphones ▼]        │   │  │
    │  │ └─────────────────────────────────────────────────────┘   │  │
    │  │                                                             │  │
    │  │ ┌─────────────────────────────────────────────────────┐   │  │
    │  │ │ Tab Selector                                        │   │  │
    │  │ │ [Capture] [Monitor] [G6 Receipts]                   │   │  │
    │  │ └─────────────────────────────────────────────────────┘   │  │
    │  │                                                             │  │
    │  │ Tab Content:                                                │  │
    │  │                                                             │  │
    │  │ ┌───────────────────────────────────────────────────────┐ │  │
    │  │ │ 1. CAPTURE TAB                                        │ │  │
    │  │ │    ┌──────────────────────────────────────────────┐   │ │  │
    │  │ │    │  ⬤ Giant Record Button (Purple/Red)          │   │ │  │
    │  │ │    │     • Purple = Ready                          │   │ │  │
    │  │ │    │     • Red = Recording (square stop icon)      │   │ │  │
    │  │ │    └──────────────────────────────────────────────┘   │ │  │
    │  │ │    ┌──────────────────────────────────────────────┐   │ │  │
    │  │ │    │  Quick Stats (when recording):               │   │ │  │
    │  │ │    │  [Level: -9 dB] [SNR: Good] [Speech: 72%]    │   │ │  │
    │  │ │    └──────────────────────────────────────────────┘   │ │  │
    │  │ │    ┌──────────────────────────────────────────────┐   │ │  │
    │  │ │    │  Instructions (when idle):                   │   │ │  │
    │  │ │    │  1⃣ Select input device                      │   │ │  │
    │  │ │    │  2⃣ Click record button                      │   │ │  │
    │  │ │    │  3⃣ Monitor quality                          │   │ │  │
    │  │ │    │  4⃣ View gate receipts                       │   │ │  │
    │  │ │    └──────────────────────────────────────────────┘   │ │  │
    │  │ └───────────────────────────────────────────────────────┘ │  │
    │  │                                                             │  │
    │  │ ┌───────────────────────────────────────────────────────┐ │  │
    │  │ │ 2. MONITOR TAB (AudioMonitorView)                     │ │  │
    │  │ │    ┌──────────────────────────────────────────────┐   │ │  │
    │  │ │    │  🔴 LIVE Indicator (blinking when recording) │   │ │  │
    │  │ │    └──────────────────────────────────────────────┘   │ │  │
    │  │ │    ┌──────────────────────────────────────────────┐   │ │  │
    │  │ │    │  Level Meter (dBFS scale)                    │   │ │  │
    │  │ │    │   0 ────  🔴 Red                             │   │ │  │
    │  │ │    │ -12 ────  🟠 Amber                           │   │ │  │
    │  │ │    │ -24 ────  🟢 Green                           │   │ │  │
    │  │ │    │ -48 ────  🔵 Blue                            │   │ │  │
    │  │ │    │ -96 ────  🔵 Blue (silence)                  │   │ │  │
    │  │ │    │                                              │   │ │  │
    │  │ │    │  Current: -9 dBFS                            │   │ │  │
    │  │ │    └──────────────────────────────────────────────┘   │ │  │
    │  │ │    ┌──────────────────────────────────────────────┐   │ │  │
    │  │ │    │  Quality Metrics (updated every 1s):         │   │ │  │
    │  │ │    │  • SNR: 25 dB [Good ✅]                      │   │ │  │
    │  │ │    │  • Speech: 72% [Active ✅]                   │   │ │  │
    │  │ │    │  • Noise Floor: -45 dB                       │   │ │  │
    │  │ │    │  • Clipping: 0% (no warnings)                │   │ │  │
    │  │ │    └──────────────────────────────────────────────┘   │ │  │
    │  │ └───────────────────────────────────────────────────────┘ │  │
    │  │                                                             │  │
    │  │ ┌───────────────────────────────────────────────────────┐ │  │
    │  │ │ 3. G6 RECEIPTS TAB (GateReceiptView)                  │ │  │
    │  │ │    ┌──────────────────────────────────────────────┐   │ │  │
    │  │ │    │  Receipt Card 1:                             │   │ │  │
    │  │ │    │  ✅ MACOS.MIC.CAPTURE        2m ago          │   │ │  │
    │  │ │    │  🔊 X6 Bluetooth Headphones                  │   │ │  │
    │  │ │    │  SESSION REF: A1B2C3D4 ••• [📋 Copy]        │   │ │  │
    │  │ │    │  🔒 Ready for AKRON v1 signature             │   │ │  │
    │  │ │    └──────────────────────────────────────────────┘   │ │  │
    │  │ │    ┌──────────────────────────────────────────────┐   │ │  │
    │  │ │    │  Receipt Card 2:                             │   │ │  │
    │  │ │    │  ✅ MACOS.MIC.CAPTURE        15m ago         │   │ │  │
    │  │ │    │  💻 MacBook Pro Microphone                   │   │ │  │
    │  │ │    │  SESSION REF: C5D6E7F8 ••• [📋 Copy]        │   │ │  │
    │  │ │    │  🔒 Ready for AKRON v1 signature             │   │ │  │
    │  │ │    └──────────────────────────────────────────────┘   │ │  │
    │  │ └───────────────────────────────────────────────────────┘ │  │
    │  └───────────────────────────────────────────────────────────┘  │
    └─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│  GATE RECEIPT LAYER                                                     │
└─────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────┐
    │  GeometryGateReceipt (v0 → v1 ready)                            │
    │  ┌───────────────────────────────────────────────────────────┐  │
    │  │ sessionRef: "deviceID:timestamp"                          │  │
    │  │ timestamp: Date                                           │  │
    │  │ capability: "macos.mic.capture"                           │  │
    │  │ deviceName: "X6 Bluetooth Headphones"                     │  │
    │  │ sha256Hint: "A1B2C3D4" (first 8 chars)                    │  │
    │  └───────────────────────────────────────────────────────────┘  │
    │                                                                  │
    │  Storage: UserDefaults["field.geometry.gate.log"]               │
    │  Retention: Last 50 sessions                                     │
    │  v1 Upgrade: AKRON cryptographic signature                       │
    └─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│  DATA FLOW (End-to-End)                                                 │
└─────────────────────────────────────────────────────────────────────────┘

    🎧 X6 Mic (analog audio)
         ↓
    Bluetooth A2DP → Mac Studio
         ↓
    Core Audio (native sample rate: 44.1/48 kHz)
         ↓
    AudioDeviceManager (device selection)
         ↓
    AVAudioEngine (inputNode.installTap)
         ↓
    AVAudioConverter (→ 16kHz mono Float32)
         ↓
    Buffer accumulation (100ms = 1600 samples)
         ↓
    PCM16LE conversion + Base64 encoding
         ↓
    MurmurPacket<AudioChunkPayload> {
        schema: "FIELD_MURMUR_PACKET_V0"
        deviceID: "UUID"
        kind: "audio_chunk"
        payload: {
            codec: "pcm16le"
            sampleRateHz: 16000
            bytesB64: "..."
            vad: { speech: true, prob: 0.72 }
        }
    }
         ↓
    MurmurQueue.enqueue(.audioChunk)
         ↓
    MurmurTransport (WebSocket)
         ↓
    SpinningTop MCP (port 7410)
         ↓
    FIELD Backend Processing

    Every 1 second:
         ↓
    MurmurPacket<QualityFramePayload> {
        kind: "quality_frame"
        payload: {
            rmsDb: -9.0
            snrEst: 25.0
            vadSpeechRatio: 0.72
            clipRate: 0.0
            noiseFloorDb: -45.0
        }
    }
         ↓
    Published to MacOSMurmurController.lastQuality
         ↓
    UI updates (AudioMonitorView)

    On session end:
         ↓
    GeometryGateReceipt.log()
         ↓
    UserDefaults["field.geometry.gate.log"]
         ↓
    GateReceiptView displays

┌─────────────────────────────────────────────────────────────────────────┐
│  INTEGRATION POINTS                                                     │
└─────────────────────────────────────────────────────────────────────────┘

    DOJOApp (Main App)
      ├─ WindowGroup 1: "DOJO Chat"
      │    └─ DOJOChatView (existing chat interface)
      │
      └─ WindowGroup 2: "G6 Audio Capture" ⌘⇧N
           └─ DOJOAudioCaptureView
                ├─ MacOSMurmurController (@StateObject)
                │    ├─ AudioDeviceManager
                │    └─ MurmurCaptureService
                │
                ├─ AudioMonitorView (real-time quality)
                └─ GateReceiptView (session verification)

┌─────────────────────────────────────────────────────────────────────────┐
│  QUALITY METRICS (Real-time Computation)                                │
└─────────────────────────────────────────────────────────────────────────┘

    Every 100ms (chunk):
      • RMS level (dBFS) via vDSP_rmsqv
      • VAD frame detection (threshold: -36 dBFS)

    Every 1s (quality frame):
      • SNR estimate (signal vs noise floor)
      • Noise floor (RMS - 20 dB heuristic)
      • Clip rate (samples > 0.99 amplitude)
      • Speech ratio (VAD frames / total frames)

    Color coding:
      • SNR > 30 dB  → Green (Excellent)
      • SNR 20-30 dB → Blue (Good)
      • SNR 10-20 dB → Amber (Fair)
      • SNR < 10 dB  → Red (Poor)

┌─────────────────────────────────────────────────────────────────────────┐
│  FILE STRUCTURE                                                         │
└─────────────────────────────────────────────────────────────────────────┘

    DOJOApp/
      ├─ DOJOApp.swift (main app + window groups)
      │
      ├─ Audio Capture System/
      │   ├─ AudioDeviceManager.swift (device discovery)
      │   ├─ MacOSMurmurController.swift (capture pipeline)
      │   ├─ DOJOAudioCaptureView.swift (main 3-tab UI)
      │   ├─ AudioMonitorView.swift (real-time quality)
      │   └─ GateReceiptView.swift (session verification)
      │
      ├─ Shared (DOJOShared framework)/
      │   ├─ MurmurCaptureService.swift (iOS + macOS)
      │   ├─ MurmurPacket.swift (schema + payloads)
      │   ├─ MurmurTransport.swift (WebSocket)
      │   └─ MurmurQueue.swift (actor queue)
      │
      └─ Documentation/
          ├─ G6_HARDWARE_GATE_README.md (comprehensive guide)
          ├─ G6_COMPLETION_SUMMARY.md (project status)
          ├─ G6_QUICK_START.md (30-second test)
          └─ G6_ARCHITECTURE.md (this file)

┌─────────────────────────────────────────────────────────────────────────┐
│  KEY CAPABILITIES                                                       │
└─────────────────────────────────────────────────────────────────────────┘

    ✅ Bluetooth device detection (X6 headphones)
    ✅ USB device detection
    ✅ Built-in mic detection
    ✅ Hot-plug event handling
    ✅ Device selection persistence
    ✅ Real-time audio capture (16kHz mono PCM16LE)
    ✅ Quality metrics (RMS, SNR, VAD, Clip, Noise)
    ✅ Live level meter visualization
    ✅ Session logging (gate receipts)
    ✅ AKRON v1 signature readiness
    ✅ Multi-window macOS app
    ✅ Keyboard shortcuts (⌘⇧N)

┌─────────────────────────────────────────────────────────────────────────┐
│  FUTURE ENHANCEMENTS (v1)                                               │
└─────────────────────────────────────────────────────────────────────────┘

    🔜 Waveform visualization (real-time audio graph)
    🔜 Session export (audio + metadata to disk)
    🔜 AKRON cryptographic signatures (replace sha256Hint)
    🔜 Backend sync (POST receipts to SpinningTop)
    🔜 Cross-device session linking (iOS + macOS)
    🔜 Voice profile fingerprinting
    🔜 Distributed ledger integration
    🔜 Geometry transforms on audio sessions

┌─────────────────────────────────────────────────────────────────────────┐
│  STATUS: ✅ ALL COMPONENTS COMPLETE                                     │
└─────────────────────────────────────────────────────────────────────────┘

    Device Manager:       ✅ Complete
    Capture Controller:   ✅ Complete
    Real-time Monitor:    ✅ Complete
    Gate Receipts:        ✅ Complete
    macOS Integration:    ✅ Complete
    Documentation:        ✅ Complete

    READY FOR X6 TESTING! 🎧
```

---

**G6 Hardware Gate Architecture v1.0**  
*DOJO Suite — FIELD murmur system*  
*Built with Swift + SwiftUI for macOS 14+*  
*2026-06-21*

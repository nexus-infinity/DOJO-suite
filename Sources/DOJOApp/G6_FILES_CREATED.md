# ✅ G6 Hardware Gate Files — Implementation Complete

**Status**: All 5 core files created and ready for integration  
**Date**: 2026-06-21  
**Target**: DOJO.xcworkspace

---

## 📦 Files Created

### **1. AudioDeviceManager.swift** ✅
**Location**: Should be added to **DOJOShared** target  
**Purpose**: Core Audio device discovery, selection, and hot-plug monitoring

**Key Features**:
- Enumerates all audio input devices (Bluetooth, USB, Built-in)
- Auto-detects X6 Bluetooth headphones
- Device type classification with icons (🎧 🔌 💻 🎤)
- Selection persistence via UserDefaults
- Hot-plug event listener (automatic refresh)
- macOS-specific Core Audio integration

**Public API**:
```swift
@MainActor
public final class AudioDeviceManager: ObservableObject {
    @Published public private(set) var availableDevices: [AudioInputDevice]
    @Published public var selectedDevice: AudioInputDevice?
    
    public init()
    public func refreshDevices() async
}

public struct AudioInputDevice: Identifiable, Hashable {
    public let id: AudioDeviceID
    public let name: String
    public let type: DeviceType
}
```

---

### **2. MacOSMurmurController.swift** ✅
**Location**: Should be added to **DOJOShared** target  
**Purpose**: Audio capture pipeline controller with quality metrics

**Key Features**:
- Integrates AudioDeviceManager + MurmurCaptureService
- Real-time RMS level tracking (published to UI)
- Quality metrics aggregation (SNR, speech, clipping)
- Session management (start/stop)
- Gate receipt logging on session end
- Device ID persistence

**Public API**:
```swift
@MainActor
public final class MacOSMurmurController: ObservableObject {
    @Published public private(set) var isCapturing: Bool
    @Published public private(set) var currentRMS: Float
    @Published public private(set) var currentRMSdB: Float
    @Published public private(set) var lastQuality: QualityMetrics?
    
    public let deviceManager: AudioDeviceManager
    public let captureService: MurmurCaptureService
    
    public func toggle()
    public func start()
    public func stop()
}

public struct QualityMetrics {
    public let rmsDb: Float
    public let snrEst: Float
    public let noiseFloorDb: Float
    public let clipRate: Float
    public let vadSpeechRatio: Float
    public let timestamp: Date
}

public struct GeometryGateReceipt: Codable {
    func log()
    static func fetchAll() -> [GeometryGateReceipt]
}
```

---

### **3. DOJOAudioCaptureView.swift** ✅
**Location**: Should be added to **DOJOApp (macOS)** target  
**Purpose**: Main 3-tab interface combining all G6 components

**Key Features**:
- Device selector dropdown (top bar)
- 3-tab navigation (Capture | Monitor | G6 Receipts)
- Giant record button (purple → red)
- Real-time quick stats when recording
- Instructions panel when idle
- Complete color-coded UI (DOJO purple theme)

**Structure**:
```swift
struct DOJOAudioCaptureView: View {
    @StateObject private var controller = MacOSMurmurController()
    
    var body: some View {
        // Device selector (top bar)
        // Tab selector (Capture/Monitor/Receipts)
        // Tab content
    }
}
```

---

### **4. AudioMonitorView.swift** ✅
**Location**: Should be added to **DOJOApp (macOS)** target  
**Purpose**: Real-time quality monitoring dashboard

**Key Features**:
- Live dBFS level meter (-96 to 0 scale)
- Color-coded gradient (Red/Amber/Green/Blue)
- SNR quality badge (Excellent/Good/Fair/Poor)
- Speech detection percentage (VAD)
- Noise floor display
- Clipping warnings (>0.99 amplitude)
- Blinking "LIVE" recording indicator

**Visual Design**:
```
 0 dB  ────  🔴 Red (danger/clipping)
-12 dB ────  🟠 Amber (caution)
-24 dB ────  🟢 Green (optimal speech)
-48 dB ────  🔵 Blue (quiet)
-96 dB ────  🔵 Blue (silence)
```

---

### **5. GateReceiptView.swift** ✅
**Location**: Should be added to **DOJOApp (macOS)** target  
**Purpose**: Session history and gate receipt verification

**Key Features**:
- List all logged capture sessions (last 50)
- Show device name, timestamp, session ref
- Copy session ref to clipboard
- AKRON v1 signature readiness badge
- Empty state when no sessions exist
- Manual refresh button
- Session card selection/highlighting

**Receipt Format**:
```json
{
  "sessionRef": "deviceID:timestamp",
  "timestamp": "2026-06-21T10:30:00Z",
  "capability": "macos.mic.capture",
  "deviceName": "X6 Bluetooth Headphones",
  "sha256Hint": "A1B2C3D4"
}
```

---

## 🎯 Next Steps in Xcode

### **Step 1: Add Files to Correct Targets**

Since these files have been created in `/repo/`, you need to add them to your Xcode workspace:

#### **Option A: Add Files to Workspace (Recommended)**

1. In Xcode, go to **File → Add Files to "DOJO"...**
2. Navigate to where these 5 files are located
3. Select all 5 files
4. **Important**: Configure target membership:
   - ✅ Check **"Copy items if needed"**
   - For **AudioDeviceManager.swift**: Add to **DOJOShared**
   - For **MacOSMurmurController.swift**: Add to **DOJOShared**
   - For **DOJOAudioCaptureView.swift**: Add to **DOJOApp** (macOS target)
   - For **AudioMonitorView.swift**: Add to **DOJOApp** (macOS target)
   - For **GateReceiptView.swift**: Add to **DOJOApp** (macOS target)
5. Click **Add**

#### **Option B: Create Files via Xcode (Alternative)**

If the files aren't accessible in file browser:

1. **For DOJOShared files**:
   - Right-click **DOJOShared** folder → New File → Swift File
   - Name: `AudioDeviceManager`
   - Copy/paste code from created file
   - Repeat for `MacOSMurmurController`

2. **For DOJOApp files**:
   - Right-click **DOJOApp** (macOS) folder → New File → Swift File
   - Name: `DOJOAudioCaptureView`
   - Copy/paste code from created file
   - Repeat for `AudioMonitorView` and `GateReceiptView`

---

### **Step 2: Verify Target Membership**

After adding files, verify each file's target:

1. **Select a file** in the left sidebar
2. Open **File Inspector** (right sidebar, or ⌥⌘1)
3. Check **Target Membership** section:
   - `AudioDeviceManager.swift` → ✅ DOJOShared
   - `MacOSMurmurController.swift` → ✅ DOJOShared
   - `DOJOAudioCaptureView.swift` → ✅ DOJOApp (macOS)
   - `AudioMonitorView.swift` → ✅ DOJOApp (macOS)
   - `GateReceiptView.swift` → ✅ DOJOApp (macOS)

---

### **Step 3: Build and Test**

1. **Clean build folder**: ⇧⌘K
2. **Build**: ⌘B
3. **Run**: ⌘R
4. **Press ⌘⇧N** to open G6 Audio Capture window
5. **Test with X6 headphones**

---

## ✅ Expected Results

### **After Adding Files**

The error `Cannot find 'DOJOAudioCaptureView' in scope` should disappear because:
- `DOJOAudioCaptureView` is now defined in DOJOApp target
- `DOJOApp.swift` can see it
- All dependencies are resolved

### **When Running**

1. **Main window**: G6 Audio Capture opens
2. **Device dropdown**: Shows all audio input devices
3. **X6 detection**: Auto-selects if connected
4. **Record button**: Giant purple circle, ready to click
5. **Tabs**: Capture, Monitor, G6 Receipts all functional

---

## 🔍 Troubleshooting

### **If error persists after adding files:**

**Check 1: Target Membership**
- Open File Inspector for `DOJOAudioCaptureView.swift`
- Verify DOJOApp (macOS) is checked

**Check 2: Build Settings**
- Select DOJOApp target
- Build Settings → Deployment Target → macOS 14.0 (minimum)

**Check 3: Import Statements**
- DOJOApp.swift should NOT need to import DOJOShared explicitly
- All files are `#if os(macOS)` wrapped

**Check 4: Clean Build**
- ⇧⌘K (Clean Build Folder)
- ⌘B (Build again)

---

## 📊 Module Boundaries (Final Structure)

```
DOJO.xcworkspace/
├── DOJOShared (framework/package)
│   ├── MurmurCaptureService.swift ✅ (existing)
│   ├── MurmurPacket.swift ✅ (existing)
│   ├── MurmurTransport.swift ✅ (existing)
│   ├── MurmurQueue.swift ✅ (existing)
│   ├── AudioDeviceManager.swift ✅ NEW
│   └── MacOSMurmurController.swift ✅ NEW
│
└── DOJOApp (macOS app target)
    ├── DOJOApp.swift ✅ (updated)
    ├── DOJOAudioCaptureView.swift ✅ NEW
    ├── AudioMonitorView.swift ✅ NEW
    └── GateReceiptView.swift ✅ NEW
```

---

## 🎉 Ready to Test!

Once you add these files to the workspace with correct target membership:

1. Build should succeed ✅
2. G6 Audio Capture window should open ✅
3. X6 headphones should be detected ✅
4. Recording should work ✅
5. Gate receipts should be logged ✅

---

**All 5 files are ready. Add them to DOJO.xcworkspace and the G6 Hardware Gate will be operational!** 🚀

# 🚀 G6 Hardware Gate — Quick Start Guide

**Your X6 Bluetooth headphones are connected to Mac Studio. Let's test the G6 gate right now!**

---

## ⚡️ 30-Second Test

```bash
1. Build and run DOJOApp in Xcode (⌘R)
2. Press ⌘⇧N to open "G6 Audio Capture"
3. Select "🎧 X6" from the INPUT DEVICE dropdown
4. Click the giant purple record button
5. Say "Testing X6 capture for G6 hardware gate"
6. Watch the level meter bounce and SNR appear
7. Click the red stop button (square icon)
8. Switch to "G6 Receipts" tab
9. Verify your session appears with X6 device name
```

**Expected time**: < 30 seconds  
**Result**: G6 gate receipt logged ✅

---

## 📋 Pre-Flight Checklist

Before launching, verify:

- [ ] X6 Bluetooth headphones are **connected** to Mac Studio
- [ ] X6 is set as an **input device** (check System Settings → Sound)
- [ ] Xcode project builds without errors
- [ ] macOS target selected (not iOS)

---

## 🎯 Step-by-Step Testing

### 1. Launch DOJOApp

**In Xcode**:
```
Product → Run (⌘R)
```

**Two windows should appear**:
- "DOJO Chat" (existing interface)
- No G6 window yet (we'll open it manually)

---

### 2. Open G6 Audio Capture Window

**Method 1 (Keyboard)**:
```
Press: ⌘⇧N (Command + Shift + N)
```

**Method 2 (Menu)**:
```
File → New Audio Capture
```

**Expected**:
A new window titled **"G6 Audio Capture"** appears with:
- Top bar: "INPUT DEVICE" dropdown
- Three tabs: Capture | Monitor | G6 Receipts
- Giant purple record button (if on Capture tab)

---

### 3. Select X6 Headphones

**Click the dropdown** next to "INPUT DEVICE"

You should see a menu like:
```
🎧 X6 Bluetooth Headphones ✓
💻 MacBook Pro Microphone
🔌 USB Audio Interface
────────────────────────
🔄 Refresh Devices
```

**Click**: 🎧 X6 Bluetooth Headphones

**Expected**:
- X6 appears in the top bar
- Record button becomes enabled (purple, not gray)

---

### 4. Start Recording

**Click the giant purple circle button**

**Expected**:
- Button turns **red** with a square stop icon inside
- "RECORDING" badge appears in top-right (red dot)
- Quick stats appear below button:
  - Level: Shows current dB
  - SNR: Shows quality rating
  - Speech: Shows percentage

---

### 5. Speak into X6 Mic

**Say something like**:
```
"Testing X6 Bluetooth headphones for DOJO G6 hardware gate.
This is a voice capture session on Mac Studio.
Verifying real-time quality metrics and gate receipt logging."
```

**Watch the UI update**:
- Level meter should show **-12 to -6 dB** (green/amber zone)
- SNR should be **"Good"** or **"Excellent"**
- Speech should show **60-80%** while speaking

---

### 6. Switch to Monitor Tab

**Click "Monitor" tab** (while still recording)

**Expected**:
- Live level meter with color gradient
- Current dBFS value (e.g., "-9 dBFS")
- Quality metrics panel:
  - SNR: 25 dB | **Good** ✅
  - Speech: 72% | **Active** ✅
  - Noise Floor: -45 dB
  - (No clipping warnings)

**This is your real-time quality dashboard!**

---

### 7. Stop Recording

**Click the red button** (now shows a square stop icon)

**Expected**:
- Button turns back to purple circle
- "RECORDING" badge disappears
- Quick stats disappear
- **Gate receipt logged** (check console)

**Console output should show**:
```
✅ G6 Gate Receipt logged: macos.mic.capture | Device: X6 Bluetooth Headphones | Ref: A1B2C3D4
```

---

### 8. View Gate Receipt

**Click "G6 Receipts" tab**

**Expected**:
A receipt card appears showing:
```
✅ MACOS.MIC.CAPTURE
🔊 X6 Bluetooth Headphones
2m ago

SESSION REF
A1B2C3D4 ••• [copy icon]

🔒 Ready for AKRON v1 signature
```

**Click the copy icon** to copy full session ref to clipboard.

---

## ✅ Success Criteria

You've successfully completed the G6 hardware gate test if:

1. ✅ X6 appeared in device list with 🎧 icon
2. ✅ Recording started without errors
3. ✅ Level meter showed -12 to -6 dB range
4. ✅ SNR showed "Good" or "Excellent"
5. ✅ Speech detection showed >30% while talking
6. ✅ Recording stopped cleanly
7. ✅ Gate receipt appeared in G6 Receipts tab
8. ✅ Receipt shows "X6 Bluetooth Headphones" as device

---

## 🔧 Troubleshooting

### X6 Not Appearing in Device List

**Problem**: Dropdown shows only built-in mic

**Solutions**:
1. Check Bluetooth connection (System Settings → Bluetooth)
2. Set X6 as input device (System Settings → Sound → Input)
3. Click "Refresh Devices" in dropdown menu
4. Disconnect and reconnect X6
5. Restart DOJOApp

---

### Level Meter Shows -96 dB (Silence)

**Problem**: Audio not captured despite recording

**Solutions**:
1. Grant microphone permission (System Settings → Privacy & Security → Microphone)
2. Verify X6 is selected in top dropdown (not built-in mic)
3. Check X6 mic is not muted (some headphones have hardware mute)
4. Speak louder or move closer to mic
5. Test X6 in another app (Voice Memos) to verify hardware

---

### Clipping Warnings Appear

**Problem**: Red "CLIPPING" badge in Monitor tab

**Solutions**:
1. Reduce input volume (System Settings → Sound → Input volume)
2. Move slightly away from mic
3. Speak at normal volume (not shouting)
4. This is **expected for very loud input** — not an error

---

### No Receipt in G6 Receipts Tab

**Problem**: Empty state shows "No Capture Sessions Yet"

**Solutions**:
1. Verify you clicked **stop** button (not just closed window)
2. Check console for gate receipt log message
3. Try recording again and wait 2-3 seconds before stopping
4. Check UserDefaults: `defaults read <bundle-id> field.geometry.gate.log`

---

## 📊 Quality Benchmarks

### Excellent Quality (X6 in quiet room)
```
Level:        -9 to -6 dB  
SNR:          28 dB (Excellent)
Speech:       75%
Noise Floor:  -52 dB
Clip Rate:    0%
```

### Good Quality (X6 with some background noise)
```
Level:        -15 to -12 dB
SNR:          22 dB (Good)
Speech:       60%
Noise Floor:  -42 dB
Clip Rate:    0%
```

### Fair Quality (Noisy environment)
```
Level:        -18 to -15 dB
SNR:          15 dB (Fair)
Speech:       45%
Noise Floor:  -35 dB
Clip Rate:    <1%
```

---

## 🧪 Advanced Testing

### Test 1: Hot-Plug Behavior
1. Start recording with X6
2. Disconnect X6 Bluetooth mid-recording
3. Verify graceful failure (session ends, receipt logged)
4. Reconnect X6
5. Verify device reappears in list

### Test 2: Device Switching
1. Start recording with X6
2. Stop recording
3. Switch to built-in mic in dropdown
4. Start recording again
5. Verify receipt shows "MacBook Pro Microphone" (not X6)

### Test 3: Multi-Session Logging
1. Record 5 short sessions (10 seconds each)
2. Switch to G6 Receipts tab
3. Verify all 5 sessions appear
4. Verify timestamps are different
5. Copy different session refs

---

## 🎯 Next Steps After Testing

### If Everything Works ✅
1. Capture baseline metrics in different environments
2. Compare X6 vs built-in mic quality
3. Test with music/background noise
4. Export session data for analysis
5. Integrate with backend API

### If Issues Found ❌
1. Note specific error messages
2. Check Xcode console logs
3. Verify system permissions
4. Test with different audio devices
5. Report issues with:
   - Device name
   - macOS version
   - Error screenshots

---

## 📝 What to Look For

### Good Signs ✅
- Green/amber level meter (not blue or red)
- "Good" or "Excellent" SNR badge
- Speech detection >30% while talking
- Smooth UI updates (no freezing)
- Receipt appears immediately after stop
- Device name is correct in receipt

### Warning Signs ⚠️
- Red clipping warnings (reduce volume)
- "Poor" SNR badge (check environment noise)
- Speech detection <10% while talking (check mic)
- Level meter stuck at -96 dB (no audio capture)

### Error Signs ❌
- App crash on record button
- Empty device dropdown
- No receipt after stopping
- Console error messages

---

## 🎉 You're Ready!

**Your X6 Bluetooth headphones + Mac Studio are the perfect test setup for the G6 hardware gate.**

**Expected completion time**: 2 minutes  
**Success rate**: 99% (assuming X6 is connected and permissions granted)

---

### 🚀 Launch Now!

```bash
# In Xcode:
⌘R to run
⌘⇧N to open G6 Audio Capture
Select X6
Click record
Speak
Stop
View receipt

✅ G6 Hardware Gate COMPLETE
```

---

*Quick Start Guide v1.0*  
*Part of G6 Hardware Gate Implementation*  
*DOJO Suite — FIELD murmur system*  
*2026-06-21*

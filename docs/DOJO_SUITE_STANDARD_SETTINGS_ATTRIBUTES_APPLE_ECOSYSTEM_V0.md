# DOJO Suite — Standard Settings Attributes (Apple Ecosystem) V0

**Status:** `SEATED.SPEC` · walk-around for Settings design across Mac · iPhone · iPad · CarPlay · Watch
**Purpose:** Separate **Apple system-managed** attributes from **DOJO app Settings**, so mic/speakers and peers behave correctly across the ecosystem without clutter or private parallel “device control.”
**Not:** full Settings UI rewrite · CarPlay runtime · claiming every TCC path is wired

**Parents:**
`DOJO_TODAY_PANEL_CONTRACT_V0.md` § Settings ·
`CONNECTOR_MANDELA_AUTH_STORAGE_MULTISURFACE_V0.md` § multi-surface ·
`DOJO_TODAY_UNDER_THE_HOOD_INSPECTOR_CONTRACT_V0.md` (Settings ≠ Inspector) ·
G6 / Murmur audio capture notes under `Sources/DOJOApp/G6_*`

---

## Product law

```text
Settings configure the app.
Apple System Settings own the ecosystem device graph.
DOJO may SELECT and PREFER devices; Apple enumerates and routes them.
Privacy grants live in Apple Privacy & Security — DOJO only requests and deep-links.
One glove · many surfaces · same attribute genotype · different controls per form factor.
```

```text
In-app: “Use this mic / this output for DOJO”
System: “Which hardware exists, Bluetooth pairs, and which apps may touch mic/camera”
```

---

## 1. Two homes (do not collapse)

| Home | Owns | Examples |
|------|------|----------|
| **Apple System Settings** (macOS) / **Settings app** (iPhone/iPad) | Device graph, pairing, OS privacy TCC, default sound I/O, Focus, Apple ID, Continuity | Sound → Input/Output · Privacy → Microphone · Bluetooth · Notifications · Screen Time |
| **DOJO Suite Settings** | App preferences, provider keys, connectors, receipts policy, **preferred** I/O for this app, in-app behaviour | Models · API keys · Connectors · Voice & capture (prefer device) · Appearance · Storage |

**Rule:** If the user is fixing “AirPods not in the list,” that is often **Bluetooth + System Sound**, not a DOJO bug. DOJO Settings should **deep-link** and show status, not reimplement Apple’s device manager.

---

## 2. Audio — microphone & speakers (first-class)

### 2.1 Genotype attributes

| Attribute | Meaning | Apple side | DOJO Settings side |
|-----------|---------|------------|---------------------|
| **Microphone permission** | May app capture audio? | Privacy & Security → Microphone (TCC) | Status · Request · “Open System Settings” |
| **Speech recognition permission** | May app use speech APIs? | Privacy → Speech Recognition | Status · Request (if used) |
| **Input device preference** | Which mic DOJO prefers when multiple exist | System enumerates devices; Continuity/Bluetooth ownership | Picker of **available** inputs · “System default” option |
| **Output device preference** | Which speakers/headphones for DOJO playback | System Sound / Control Center routing | Picker of **available** outputs · “System default” |
| **Input level / meter** | Signal present? | System input level (Mac Sound) | In-app meter while testing capture |
| **Mute / duck** | Session behaviour | Audio session category (iOS/iPad) | Play-and-record vs play · duck others (advanced) |
| **Bluetooth / AirPods quality mode** | HQ recording when available | System + AVAudioSession options | Prefer HQ when supported; don’t invent pairing UI |
| **Sample / pipeline prefs** | App capture quality | — | 16 kHz murmur defaults etc. (advanced / G6) |

### 2.2 Surface notes

| Surface | Mic / speaker reality |
|---------|----------------------|
| **Mac** | Full device list; AVAudioEngine / HAL; System Settings → Sound is authority for hardware; app may pick among allowed devices |
| **iPhone** | Route changes (Receiver, Speaker, Bluetooth); system input picker APIs where available; permission banners; Control Center shows recent mic use |
| **iPad** | Similar to iPhone + external mics/USB more common; hybrid UI for pickers |
| **CarPlay** | Vehicle audio route; **no** full device catalog; use system CarPlay audio session; short turns only |
| **Watch** | Mic for short capture; speaker/haptic limited; no full I/O manager |

### 2.3 Standard UX pattern (Voice & capture)

```text
Settings → Voice & capture

Microphone
  Status: Allowed | Denied | Not determined
  [Request access]  [Open System Settings…]
  Preferred input:  [ System default ▾ | Built-in | X6 | AirPods … ]
  [Test capture]    ← live meter; not a fake green

Speakers / output
  Preferred output: [ System default ▾ | … ]
  [Test tone]       ← optional, short

Speech (if enabled)
  Status + deep-link

Advanced (disclosure)
  Sample rate / murmur pipeline notes
  Bluetooth high-quality recording preference
```

**Expand/contract:** only show long device lists when **more than one** non-default device exists or user opens “Choose device…”.

---

## 3. Standard settings attributes walk-around (Apple-aligned)

Grouped for DOJO Settings **sections**.
**A** = primarily Apple System · **D** = primarily DOJO · **Both** = status in app, grant/pair in Apple.

### 3.1 Identity & accounts

| Attribute | Owner | Notes |
|-----------|-------|--------|
| Apple ID / iCloud | **A** | Continuity, Keychain sync later |
| DOJO operator profile | **D** | Local label; not a second Apple ID |
| Sign-in to DOJO cloud (if any) | **D** | Optional commercial later |

### 3.2 Sound & media I/O

| Attribute | Owner | Cross-ecosystem |
|-----------|-------|-----------------|
| Mic permission | **Both** | Must work Mac↔phone handoff story |
| Preferred mic | **D** (select) / **A** (list) | Same AirPods name across devices when Continuity applies |
| Preferred speakers | **D** / **A** | CarPlay takes vehicle route |
| Camera permission | **Both** | iPhone/iPad capture; Mac if used |
| Photo Library / Files access | **Both** | Share sheet / document picker preferred over raw full-disk |
| Media library (Music) | **A** if ever used | Rare for DOJO core |

### 3.3 Privacy & sensors (Apple-managed grants)

| Attribute | Owner | Surfaces |
|-----------|-------|----------|
| Microphone | **A** grant | All capture |
| Camera | **A** | Phone/iPad |
| Speech Recognition | **A** | Voice pipeline |
| Location | **A** | Only if product needs it; default off |
| Contacts | **A** | Only if connectors need; default off |
| Calendars / Reminders | **A** | Connectors plane |
| Bluetooth | **A** | AirPods, peripherals |
| Local Network | **A** | LAN MCP / chamber discovery later |
| Motion / Focus | **A** | CarPlay/Watch context optional |
| Tracking (ATT) | **A** | Commercial builds |
| Screen Recording | **A** | Mac only if ever required — high friction |

DOJO Settings shows **status chips** + **Open System Settings**, not a second privacy console.

### 3.4 Notifications & Focus

| Attribute | Owner | Notes |
|-----------|-------|--------|
| Notification permission | **Both** | iPhone/iPad critical; Mac optional |
| Alert style / sounds | **A** + **D** defaults | Don’t rebuild Notification Center |
| Focus / Do Not Disturb | **A** | App may respect Focus filters later |
| CarPlay announcements | **A** / CarPlay | Constrained |

### 3.5 Appearance & display

| Attribute | Owner | Notes |
|-----------|-------|--------|
| Light / Dark / System | **D** (prefer System) | Follows Apple appearance |
| Text size | **A** Dynamic Type (iOS/iPad) · **D** Mac scaling | Accessibility |
| Reduce motion / transparency | **A** | App should honor |
| Orientation lock | **A** (device) | iPad/iPhone |

### 3.6 Network & Continuity (ecosystem)

| Attribute | Owner | Notes |
|-----------|-------|--------|
| Wi‑Fi / Cellular | **A** | Out of app |
| iCloud sync for DOJO data | **D** policy later + **A** iCloud | HOLD until product needs |
| Handoff / Continuity | **A** | Phone→Mac orchestration story |
| Local network discovery | **Both** | Chamber MCP later |

### 3.7 Storage & data

| Attribute | Owner | Notes |
|-----------|-------|--------|
| App storage usage | **D** show + clear cache | Paths in Inspector/Diagnostics |
| Export / import settings | **D** | MacWarp salvage discipline |
| Downloads / Files landing | **A** Files app + **D** export folder | Storage covenant |
| Delete account / wipe local | **D** | Commercial later |

### 3.8 Keyboard, Siri, dictation

| Attribute | Owner | Notes |
|-----------|-------|--------|
| Dictation | **A** | May feed capture |
| Siri / Apple Intelligence | **A** | Do not claim DOJO = Siri |
| Keyboard shortcuts | **D** (Mac) | Placeholders OK |

### 3.9 Accessibility

| Attribute | Owner | Notes |
|-----------|-------|--------|
| VoiceOver / Switch Control | **A** | App must be accessible |
| Captions / spoken content | **A** + **D** where we play audio | |

### 3.10 DOJO product settings (not Apple device graph)

| Section | Owner | Progressive disclosure |
|---------|-------|------------------------|
| Models & providers | **D** | In-play + catalog |
| API keys | **D** | In-play + Save & Test |
| Connectors (Mandela store) | **D** | Finance/Personal planes |
| MCP servers | **D** | Readiness stages |
| Receipts & history | **D** | Policy on/off |
| Memory | **D** | “Not enabled yet” |
| Privacy & local/cloud (policy) | **D** | Prefer local; not TCC console |
| Developer / Advanced | **D** | Inspector entry · Diagnostics |

---

## 4. Cross-ecosystem visibility matrix

What the operator should **recognize as the same attribute** on each surface:

| Attribute | Mac | iPhone | iPad | CarPlay | Watch |
|-----------|-----|--------|------|---------|-------|
| Mic permission | ● | ● | ● | via iPhone | ● limited |
| Prefer mic | ● full list | ● routes | ● list | system vehicle | limited |
| Prefer speakers | ● full list | ● routes | ● | vehicle | haptic/speaker limited |
| Camera | ○/● | ● | ● | — | — |
| Notifications | ○ | ● | ● | constrained | ● glance |
| Appearance | ● | ● System | ● | vehicle UI | — |
| Connectors catalog | ● full | stacked subset | hybrid | pre-auth only | — |
| API keys | ● | rare / handoff to Mac | optional | — | — |
| System Inspector | ● | light or handoff | mid | — | — |

● primary · ○ secondary · — not this surface

---

## 5. Settings section order (recommended glove)

Ordinary, human order — Apple-adjacent first, then product:

```text
1.  Account / profile
2.  Voice & capture          ← mic, speakers, test, permissions deep-link
3.  Notifications
4.  Appearance
5.  Models & providers
6.  API keys                 ← progressive in-play
7.  Connectors               ← Mandela store
8.  MCP servers
9.  Files & media
10. Receipts & history
11. Privacy & local/cloud    ← policy, not full TCC clone
12. Storage
13. Keyboard shortcuts (Mac)
14. Memory                   ← not enabled yet
15. Developer / Advanced
```

**Contract:** do not dump every TCC switch as a DOJO toggle. **Do** put Voice & capture high — multimodal glove.

---

## 6. Implementation notes (when wiring Voice & capture)

| Platform | Prefer |
|----------|--------|
| **macOS** | Enumerate input/output devices; store preferred UID; fall back to system default; deep-link `x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone` (or current macOS Settings URL) |
| **iOS / iPadOS** | `AVAudioSession` route + system input picker where available; request `recordPermission`; open app Settings URL for denied state |
| **CarPlay** | Do not offer device pickers; use active CarPlay audio route |
| **Watch** | System mic; no multi-device Settings page |

G6 / Murmur already aimed at device enumeration on Mac — align naming under **Voice & capture**, not a separate “G6 settings island.”

---

## 7. Relation to Connector Mandela & Inspector

| Concern | Home |
|---------|------|
| Prefer mic/speakers | Settings → Voice & capture |
| Why no devices listed | Status + Open Bluetooth / Sound (System) |
| Connector OAuth | Settings → Connectors |
| Runtime “which route active now” | Optional Inspector → short status; not Settings essay |
| Raw HAL / process | Diagnostics |

---

## 8. HOLD pins

| HOLD | Meaning |
|------|---------|
| `HOLD.VoiceCaptureSettingsUINotShipped` | Section named; pickers not fully wired in Today Settings |
| `HOLD.PreferredDeviceSyncAcrossAppleID` | Prefer-local device IDs may not Continuity-sync |
| `HOLD.CarPlayAudioRouteAppControl` | Vehicle route owned by system |
| `HOLD.WatchAudioSettingsMinimal` | No full I/O manager on Watch |

---

## One line

**Apple owns the ecosystem device graph and privacy grants; DOJO Settings owns preferred mic/speakers and product config — deep-link System Settings, don’t rebuild them, and keep the same attribute names from Mac side-by-side to iPhone stack.**

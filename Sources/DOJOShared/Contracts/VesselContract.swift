import Foundation

// MARK: - VesselState
// Declares what operational body a DOJO-suite murmur currently inhabits.
// Every app surface must be able to truthfully declare one of these states.

public enum VesselState: String, Codable, Sendable, Equatable {
    /// Vessel can reach Mac Studio sovereign field — receipts are ratifiable now.
    case homeConnected           = "HOME_CONNECTED"
    /// Vessel is operating from local reduced representation — home unreachable.
    case localAutonomous         = "LOCAL_AUTONOMOUS"
    /// Some local capability missing; capture and receipt still possible.
    case degradedLocal           = "DEGRADED_LOCAL"
    /// Local event sealed and queued; awaiting home-field ratification.
    case queuedForRatification   = "QUEUED_FOR_RATIFICATION"
    /// Mac Studio accepted, anchored, and returned canonical receipt.
    case ratifiedByHome          = "RATIFIED_BY_HOME"
    /// Cannot verify; preserve state but do not promote any output to canon.
    case holdNoHome              = "HOLD_NO_HOME"
    /// Local state and home state disagree; operator review required.
    case conflictRequiresReview  = "CONFLICT_REQUIRES_REVIEW"
}

// MARK: - AuthorityLevel
// Labels the promotion ladder for any locally-generated output.
// No local output may silently advance to CANONICAL without home ratification.

public enum AuthorityLevel: String, Codable, Sendable, Equatable {
    /// Created on device; not yet sealed.
    case localDraft       = "LOCAL_DRAFT"
    /// Sealed locally with hash; not yet sent to home field.
    case localSealed      = "LOCAL_SEALED"
    /// Internally coherent on device; provisional confidence.
    case localProvisional = "LOCAL_PROVISIONAL"
    /// Sent to home field; awaiting response.
    case queuedForHome    = "QUEUED_FOR_HOME"
    /// Home field acknowledged receipt; not yet fully validated.
    case homeReceived     = "HOME_RECEIVED"
    /// Mac Studio validated and ratified; all chambers satisfied.
    case homeRatified     = "HOME_RATIFIED"
    /// Promoted into source-of-truth; permanent sovereign memory.
    case canonical        = "CANONICAL"
    /// Insufficient authority or missing anchor; blocked from promotion.
    case hold             = "HOLD"
}

// MARK: - SurfaceVector
// Identifies the origin surface that produced a capture or signal.
// Distinct from the murmur vessel itself — a vessel may carry multiple surface vectors.

public enum SurfaceVector: String, Codable, Sendable, Equatable {
    case iPhoneCapture    = "IPHONE_CAPTURE"     // iPhone microphone / MurmurCaptureService
    case watchSignal      = "WATCH_SIGNAL"        // watchOS sensor / WatchMurmor
    case macOSCockpit     = "MACOS_COCKPIT"       // macOS desktop / VADMicBridge
    case iPadCanvas       = "IPAD_CANVAS"         // iPad surface
    case desktopBar       = "DESKTOP_BAR"         // Floating capture bar (macOS)
    case voiceMemoFile    = "VOICE_MEMO_FILE"     // Pre-recorded audio file
    case iotSignal        = "IOT_SIGNAL"          // Room sensor / BLE edge node
    case webSurface       = "WEB_SURFACE"         // Browser / web capture
    case telephonyDialIn  = "TELEPHONY_DIAL_IN"   // Phone call input
    case unknown          = "UNKNOWN"
}

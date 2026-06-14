import CryptoKit
import Foundation

// MARK: - v0 locked constants (knobs sealed 2026-06-07)

public enum MurmurConstants {
    public static let sampleRateHz = 16_000
    public static let channels = 1
    public static let chunkDurationMs = 100
    public static let codec = "pcm16le"
    /// Samples per 100ms chunk at 16kHz mono.
    public static let chunkSampleCount = sampleRateHz * chunkDurationMs / 1_000  // 1_600

    // Leader hysteresis
    public static let minHoldMs = 2_000
    public static let switchMargin: Double = 0.15
    public static let cooldownMs = 5_000
}

// MARK: - Packet envelope (generic over payload type)

public struct MurmurPacket<Payload: Codable & Sendable>: Codable, Sendable {
    public let schema: String
    public let ts: String
    public let packetID: String
    public let deviceID: String
    public let sourceID: String
    public let streamID: String
    public let seq: Int
    public let kind: String
    public let payload: Payload

    public init(
        deviceID: String,
        sourceID: String,
        streamID: String,
        seq: Int,
        kind: String,
        payload: Payload
    ) {
        self.schema = "FIELD_MURMUR_PACKET_V0"
        self.ts = ISO8601DateFormatter().string(from: Date())
        self.packetID = UUID().uuidString
        self.deviceID = deviceID
        self.sourceID = sourceID
        self.streamID = streamID
        self.seq = seq
        self.kind = kind
        self.payload = payload
    }

    private enum CodingKeys: String, CodingKey {
        case schema, ts, seq, kind, payload
        case packetID = "packet_id"
        case deviceID = "device_id"
        case sourceID = "source_id"
        case streamID = "stream_id"
    }
}

// MARK: - Queue item (type-erased for the actor queue)

public enum QueuedMurmurPacket: Sendable {
    case audioChunk(MurmurPacket<AudioChunkPayload>)
    case qualityFrame(MurmurPacket<QualityFramePayload>)
    case heartbeat(MurmurPacket<HeartbeatPayload>)
}

// MARK: - Audio chunk payload

public struct AudioChunkPayload: Codable, Sendable {
    public let codec: String
    public let sampleRateHz: Int
    public let channels: Int
    public let frameDurationMs: Int
    public let bytesB64: String
    public let sha256: String
    public let vad: VADFlags

    public struct VADFlags: Codable, Sendable {
        public let speech: Bool
        public let prob: Float
        public init(speech: Bool, prob: Float) {
            self.speech = speech
            self.prob = prob
        }
    }

    public init(pcmData: Data, speech: Bool, vadProb: Float) {
        self.codec = MurmurConstants.codec
        self.sampleRateHz = MurmurConstants.sampleRateHz
        self.channels = MurmurConstants.channels
        self.frameDurationMs = MurmurConstants.chunkDurationMs
        self.bytesB64 = pcmData.base64EncodedString()
        self.sha256 = SHA256.hash(data: pcmData)
            .map { String(format: "%02x", $0) }.joined()
        self.vad = VADFlags(speech: speech, prob: vadProb)
    }

    private enum CodingKeys: String, CodingKey {
        case codec, channels, sha256, vad
        case sampleRateHz = "sample_rate_hz"
        case frameDurationMs = "frame_duration_ms"
        case bytesB64 = "bytes_b64"
    }
}

// MARK: - Quality frame payload

public struct QualityFramePayload: Codable, Sendable {
    public let windowMs: Int
    public let audioPresent: Bool
    public let vadSpeechRatio: Float
    public let snrEst: Float
    public let noiseFloorDb: Float
    public let rmsDb: Float
    public let clipRate: Float
    public let dropoutMs: Int
    public let latencyMs: Int
    public let jitterMs: Int
    public let batteryPct: Float
    public let thermalState: String
    public let network: String
    public let lock: LockState

    public struct LockState: Codable, Sendable {
        public let mode: String
        public let confidence: Float
        public init(mode: String = "none", confidence: Float = 0.0) {
            self.mode = mode
            self.confidence = confidence
        }
    }

    public init(
        audioPresent: Bool,
        vadSpeechRatio: Float,
        snrEst: Float,
        noiseFloorDb: Float,
        rmsDb: Float,
        clipRate: Float,
        dropoutMs: Int = 0,
        latencyMs: Int = 0,
        jitterMs: Int = 0,
        batteryPct: Float = 1.0,
        thermalState: String = "nominal",
        network: String = "wifi"
    ) {
        self.windowMs = 1_000
        self.audioPresent = audioPresent
        self.vadSpeechRatio = vadSpeechRatio
        self.snrEst = snrEst
        self.noiseFloorDb = noiseFloorDb
        self.rmsDb = rmsDb
        self.clipRate = clipRate
        self.dropoutMs = dropoutMs
        self.latencyMs = latencyMs
        self.jitterMs = jitterMs
        self.batteryPct = batteryPct
        self.thermalState = thermalState
        self.network = network
        self.lock = LockState()
    }

    private enum CodingKeys: String, CodingKey {
        case lock, network
        case windowMs = "window_ms"
        case audioPresent = "audio_present"
        case vadSpeechRatio = "vad_speech_ratio"
        case snrEst = "snr_est"
        case noiseFloorDb = "noise_floor_db"
        case rmsDb = "rms_db"
        case clipRate = "clip_rate"
        case dropoutMs = "dropout_ms"
        case latencyMs = "latency_ms"
        case jitterMs = "jitter_ms"
        case batteryPct = "battery_pct"
        case thermalState = "thermal_state"
    }
}

// MARK: - Heartbeat payload

public struct HeartbeatPayload: Codable, Sendable {
    public let appVersion: String
    public let uptimeS: Int
    public let capabilities: Capabilities

    public struct Capabilities: Codable, Sendable {
        public let audioCapture: Bool
        public let maxSampleRateHz: Int
        public let onDeviceVad: Bool

        public init(audioCapture: Bool = true, maxSampleRateHz: Int = 48_000, onDeviceVad: Bool = true) {
            self.audioCapture = audioCapture
            self.maxSampleRateHz = maxSampleRateHz
            self.onDeviceVad = onDeviceVad
        }

        private enum CodingKeys: String, CodingKey {
            case audioCapture = "audio_capture"
            case maxSampleRateHz = "max_sample_rate_hz"
            case onDeviceVad = "on_device_vad"
        }
    }

    public init(appVersion: String = "v0", uptimeS: Int = 0) {
        self.appVersion = appVersion
        self.uptimeS = uptimeS
        self.capabilities = Capabilities()
    }

    private enum CodingKeys: String, CodingKey {
        case capabilities
        case appVersion = "app_version"
        case uptimeS = "uptime_s"
    }
}

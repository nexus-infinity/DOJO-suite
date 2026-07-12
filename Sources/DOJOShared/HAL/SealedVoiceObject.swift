import CryptoKit
import Foundation

// MARK: - MFC-01 Sealed Voice Object (Track A — evidence spine only)
// Receipt: SOV-COMPUTE-SCALE-0001 Track A; BER-34 / Notion Voice Capture decision.
// Does NOT implement ParticleBoard, AKRON hosting, or State Vector.

/// Lifecycle for offline capture → later AKRON upload (upload not in this slice).
public enum SealedVoiceLifecycle: String, Codable, Sendable, Equatable {
    case localCaptured = "LOCAL_CAPTURED"
    case queued = "QUEUED"
    /// Must only be set when AKRON actually returned a receipt ID.
    case akronConfirmed = "AKRON_CONFIRMED"
}

public enum SealedVoiceAuthority: String, Codable, Sendable, Equatable {
    case localOnlyPendingAKRON = "local only / pending AKRON receipt"
}

public enum SealedVoiceCopyPolicy: String, Codable, Sendable, Equatable {
    case originalNotCopied = "ORIGINAL_NOT_COPIED"
}

public enum SealedVoiceExportPolicy: String, Codable, Sendable, Equatable {
    case explicitExportOnly = "EXPLICIT_EXPORT_ONLY"
}

/// Immutable witness packet for one capture session. Original audio bytes live at `local_file_path`.
/// `voiceRef`-style strings alone are NOT evidence — use `audio_hash` + sealed file.
public struct SealedVoiceObject: Codable, Sendable, Equatable, Identifiable {
    public var id: String { voice_object_id }

    public let voice_object_id: String
    public let sealed_object_ref: String
    public let local_file_path: String
    public let audio_hash: String
    public let hash_algorithm: String
    public let capture_timestamp: String
    public let device_session_id: String
    public let duration: Double
    public let lifecycle_state: SealedVoiceLifecycle
    public let authority_state: SealedVoiceAuthority
    public let copy_policy: SealedVoiceCopyPolicy
    public let export_policy: SealedVoiceExportPolicy
    public let akron_receipt_id: String?
    public let sample_rate_hz: Int
    public let channels: Int
    public let codec: String
    public let byte_count: Int
    public let resonance: ResonanceSignature?
    public let workLayerStatus: WorkLayerStatus?
    public let semanticHoldReasons: [SemanticHoldReason]

    public init(
        voice_object_id: String = UUID().uuidString,
        sealed_object_ref: String,
        local_file_path: String,
        audio_hash: String,
        hash_algorithm: String = "SHA-256",
        capture_timestamp: String,
        device_session_id: String,
        duration: Double,
        lifecycle_state: SealedVoiceLifecycle = .localCaptured,
        authority_state: SealedVoiceAuthority = .localOnlyPendingAKRON,
        copy_policy: SealedVoiceCopyPolicy = .originalNotCopied,
        export_policy: SealedVoiceExportPolicy = .explicitExportOnly,
        akron_receipt_id: String? = nil,
        sample_rate_hz: Int = MurmurConstants.sampleRateHz,
        channels: Int = MurmurConstants.channels,
        codec: String = MurmurConstants.codec,
        byte_count: Int,
        resonance: ResonanceSignature? = nil,
        workLayerStatus: WorkLayerStatus? = nil,
        semanticHoldReasons: [SemanticHoldReason] = []
    ) {
        self.voice_object_id = voice_object_id
        self.sealed_object_ref = sealed_object_ref
        self.local_file_path = local_file_path
        self.audio_hash = audio_hash
        self.hash_algorithm = hash_algorithm
        self.capture_timestamp = capture_timestamp
        self.device_session_id = device_session_id
        self.duration = duration
        self.lifecycle_state = lifecycle_state
        self.authority_state = authority_state
        self.copy_policy = copy_policy
        self.export_policy = export_policy
        self.akron_receipt_id = akron_receipt_id
        self.sample_rate_hz = sample_rate_hz
        self.channels = channels
        self.codec = codec
        self.byte_count = byte_count
        self.resonance = resonance
        self.workLayerStatus = workLayerStatus
        self.semanticHoldReasons = semanticHoldReasons
    }

    private enum CodingKeys: String, CodingKey {
        case voice_object_id
        case sealed_object_ref
        case local_file_path
        case audio_hash
        case hash_algorithm
        case capture_timestamp
        case device_session_id
        case duration
        case lifecycle_state
        case authority_state
        case copy_policy
        case export_policy
        case akron_receipt_id
        case sample_rate_hz
        case channels
        case codec
        case byte_count
        case resonance
        case workLayerStatus
        case semanticHoldReasons
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        voice_object_id = try container.decode(String.self, forKey: .voice_object_id)
        sealed_object_ref = try container.decode(String.self, forKey: .sealed_object_ref)
        local_file_path = try container.decode(String.self, forKey: .local_file_path)
        audio_hash = try container.decode(String.self, forKey: .audio_hash)
        hash_algorithm = try container.decode(String.self, forKey: .hash_algorithm)
        capture_timestamp = try container.decode(String.self, forKey: .capture_timestamp)
        device_session_id = try container.decode(String.self, forKey: .device_session_id)
        duration = try container.decode(Double.self, forKey: .duration)
        lifecycle_state = try container.decode(SealedVoiceLifecycle.self, forKey: .lifecycle_state)
        authority_state = try container.decode(SealedVoiceAuthority.self, forKey: .authority_state)
        copy_policy = try container.decode(SealedVoiceCopyPolicy.self, forKey: .copy_policy)
        export_policy = try container.decode(SealedVoiceExportPolicy.self, forKey: .export_policy)
        akron_receipt_id = try container.decodeIfPresent(String.self, forKey: .akron_receipt_id)
        sample_rate_hz = try container.decode(Int.self, forKey: .sample_rate_hz)
        channels = try container.decode(Int.self, forKey: .channels)
        codec = try container.decode(String.self, forKey: .codec)
        byte_count = try container.decode(Int.self, forKey: .byte_count)
        resonance = try container.decodeIfPresent(ResonanceSignature.self, forKey: .resonance)
        workLayerStatus = try container.decodeIfPresent(WorkLayerStatus.self, forKey: .workLayerStatus)
        semanticHoldReasons = try container.decodeIfPresent([SemanticHoldReason].self, forKey: .semanticHoldReasons) ?? []
    }

    /// Human-visible one-line summary (not evidence; pointer only).
    public var visibleSummary: String {
        "MFC-01 sealed · \(lifecycle_state.rawValue) · hash=\(audio_hash.prefix(12))… · \(String(format: "%.1fs", duration))"
    }
}

// MARK: - Durable store

/// File-backed sealed voice objects under Application Support.
/// Layout: …/DOJO/sealed_voice/<voice_object_id>/{audio.pcm16le, packet.json}
public final class SealedVoiceObjectStore: @unchecked Sendable {
    public static let shared = SealedVoiceObjectStore()

    private let root: URL
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }()
    private let decoder = JSONDecoder()

    public init(root: URL? = nil) {
        if let root {
            self.root = root
        } else {
            let support = FileManager.default.urls(
                for: .applicationSupportDirectory, in: .userDomainMask
            ).first!
            self.root = support.appendingPathComponent("DOJO/sealed_voice", isDirectory: true)
        }
        try? FileManager.default.createDirectory(at: self.root, withIntermediateDirectories: true)
    }

    public var directoryURL: URL { root }

    /// Seal original PCM16LE bytes. Does not copy beyond this write; policy ORIGINAL_NOT_COPIED.
    public func seal(
        pcm16le: Data,
        deviceSessionID: String,
        sampleRateHz: Int = MurmurConstants.sampleRateHz,
        channels: Int = MurmurConstants.channels
    ) throws -> SealedVoiceObject {
        guard !pcm16le.isEmpty else {
            throw SealedVoiceError.emptyAudio
        }

        let voiceObjectID = UUID().uuidString
        let objectDir = root.appendingPathComponent(voiceObjectID, isDirectory: true)
        try FileManager.default.createDirectory(at: objectDir, withIntermediateDirectories: true)

        let audioURL = objectDir.appendingPathComponent("audio.pcm16le")
        try pcm16le.write(to: audioURL, options: .atomic)

        let hash = Self.sha256Hex(pcm16le)
        let bytesPerSample = 2 * channels
        let duration = Double(pcm16le.count) / Double(sampleRateHz * bytesPerSample)
        let ts = ISO8601DateFormatter().string(from: Date())
        let sealedRef = "sealed://voice/\(voiceObjectID)"

        // Durable audio + sidecar written ⇒ LOCAL_CAPTURED then immediately QUEUED for later AKRON.
        // akron_receipt_id stays null until a real AKRON receipt exists (Track B — not this slice).
        let object = SealedVoiceObject(
            voice_object_id: voiceObjectID,
            sealed_object_ref: sealedRef,
            local_file_path: audioURL.path,
            audio_hash: hash,
            hash_algorithm: "SHA-256",
            capture_timestamp: ts,
            device_session_id: deviceSessionID,
            duration: duration,
            lifecycle_state: .queued,
            authority_state: .localOnlyPendingAKRON,
            copy_policy: .originalNotCopied,
            export_policy: .explicitExportOnly,
            akron_receipt_id: nil,
            sample_rate_hz: sampleRateHz,
            channels: channels,
            codec: MurmurConstants.codec,
            byte_count: pcm16le.count
        )

        let packetURL = objectDir.appendingPathComponent("packet.json")
        try encoder.encode(object).write(to: packetURL, options: .atomic)
        return object
    }

    public func load(voiceObjectID: String) throws -> SealedVoiceObject? {
        let packetURL = root
            .appendingPathComponent(voiceObjectID, isDirectory: true)
            .appendingPathComponent("packet.json")
        guard FileManager.default.fileExists(atPath: packetURL.path) else { return nil }
        let data = try Data(contentsOf: packetURL)
        return try decoder.decode(SealedVoiceObject.self, from: data)
    }

    public func loadAll() throws -> [SealedVoiceObject] {
        let dirs = (try? FileManager.default.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        )) ?? []
        return dirs.compactMap { dir in
            let packetURL = dir.appendingPathComponent("packet.json")
            guard let data = try? Data(contentsOf: packetURL) else { return nil }
            return try? decoder.decode(SealedVoiceObject.self, from: data)
        }
        .sorted { $0.capture_timestamp > $1.capture_timestamp }
    }

    /// Verifies on-disk audio still matches sealed hash (original not overwritten).
    public func verifyIntegrity(_ object: SealedVoiceObject) throws -> Bool {
        let data = try Data(contentsOf: URL(fileURLWithPath: object.local_file_path))
        return Self.sha256Hex(data) == object.audio_hash
    }

    public static func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}

public enum SealedVoiceError: Error, Equatable {
    case emptyAudio
}

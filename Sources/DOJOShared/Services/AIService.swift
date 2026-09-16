import Foundation
import CryptoKit
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#elseif canImport(WatchKit)
import WatchKit
#endif

// MARK: - Model Input

/// Protocol for AI model inputs
public protocol AIModelInput {
    var data: String { get }
}

/// Default AI model input implementation
public struct TextInput: AIModelInput {
    public let data: String

    public init(data: String) {
        self.data = data
    }
}

// MARK: - Model Result

/// Presentation/advisory classification. Neither case carries machine
/// authority, regardless of result shape or confidence.
public enum AIResultClassification: String, Codable, Sendable {
    case displayOnly
    case advisory
}

/// Non-authoritative AI presentation result.
///
/// Structured shape, model identity, and confidence are presentation metadata
/// only. Machine authority is represented by the separate
/// `AuthorizedAIStructuredResult`, obtainable only through AIService's
/// correlated deterministic proof gate.
public struct AIModelResult: Codable, Sendable {
    public static let presentationSchemaID = "AI_PRESENTATION_RESULT_V0"

    public let schemaID: String
    public let output: String
    public let confidence: Double?
    public let modelUsed: String
    public let deviceInfo: DeviceCapabilities
    public let classification: AIResultClassification

    public init(
        output: String,
        confidence: Double? = nil,
        modelUsed: String = "unknown",
        deviceInfo: DeviceCapabilities,
        classification: AIResultClassification = .displayOnly,
        schemaID: String = AIModelResult.presentationSchemaID
    ) {
        self.schemaID = schemaID
        self.output = output
        self.confidence = confidence
        self.modelUsed = modelUsed
        self.deviceInfo = deviceInfo
        self.classification = classification
    }

    public var isAuthorityBearing: Bool { false }
}

/// Receipt-backed structured decision admitted through the deterministic
/// verifier. It cannot be constructed outside DOJOShared.
public struct AuthorizedAIStructuredResult: Sendable {
    public static let schemaID = "AI_AUTHORIZED_STRUCTURED_RESULT_V0"

    public let output: String
    public let modelUsed: String
    public let correlationID: UUID
    public let authorityReceiptID: String
    public let verificationID: UUID
    public let sourceResultDigest: String

    fileprivate init(
        output: String,
        modelUsed: String,
        correlationID: UUID,
        authorityReceiptID: String,
        verificationID: UUID,
        sourceResultDigest: String
    ) {
        self.output = output
        self.modelUsed = modelUsed
        self.correlationID = correlationID
        self.authorityReceiptID = authorityReceiptID
        self.verificationID = verificationID
        self.sourceResultDigest = sourceResultDigest
    }
}

// MARK: - Device Capabilities

/// Device-specific capabilities for model optimization
public struct DeviceCapabilities: Codable, Sendable {
    public let platform: Platform
    public let modelIdentifier: String
    public let supportsNeuralEngine: Bool
    public let availableMemoryGB: Double
    public let recommendedQuantization: QuantizationLevel

    public enum Platform: String, Codable, Sendable {
        case macOS
        case iOS
        case iPadOS
        case watchOS
        case unknown
    }

    public enum QuantizationLevel: String, Codable, Sendable {
        case q8_0   // 8-bit quantization (high quality, larger)
        case q4_0   // 4-bit quantization (balanced)
        case q2_K   // 2-bit quantization (smallest, mobile)
    }

    public init(platform: Platform, modelIdentifier: String, supportsNeuralEngine: Bool, availableMemoryGB: Double, recommendedQuantization: QuantizationLevel) {
        self.platform = platform
        self.modelIdentifier = modelIdentifier
        self.supportsNeuralEngine = supportsNeuralEngine
        self.availableMemoryGB = availableMemoryGB
        self.recommendedQuantization = recommendedQuantization
    }

    /// Detect current device capabilities
    public static func detect() -> DeviceCapabilities {
        #if os(macOS)
        return detectMacOS()
        #elseif os(iOS)
        return detectIOS()
        #elseif os(watchOS)
        return detectWatchOS()
        #else
        return DeviceCapabilities(
            platform: .unknown,
            modelIdentifier: "unknown",
            supportsNeuralEngine: false,
            availableMemoryGB: 0,
            recommendedQuantization: .q2_K
        )
        #endif
    }

    #if os(macOS)
    private static func detectMacOS() -> DeviceCapabilities {
        let memoryGB = Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824.0
        let hasNeuralEngine = ProcessInfo.processInfo.processorCount >= 8 // Rough heuristic for Apple Silicon

        let quantization: QuantizationLevel
        if memoryGB >= 16 {
            quantization = .q8_0
        } else if memoryGB >= 8 {
            quantization = .q4_0
        } else {
            quantization = .q2_K
        }

        return DeviceCapabilities(
            platform: .macOS,
            modelIdentifier: "Mac",
            supportsNeuralEngine: hasNeuralEngine,
            availableMemoryGB: memoryGB,
            recommendedQuantization: quantization
        )
    }
    #endif

    #if os(iOS)
    private static func detectIOS() -> DeviceCapabilities {
        let memoryGB = Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824.0
        let device = UIDevice.current
        let isPad = device.userInterfaceIdiom == .pad

        return DeviceCapabilities(
            platform: isPad ? .iPadOS : .iOS,
            modelIdentifier: device.model,
            supportsNeuralEngine: true, // Most modern iOS devices have Neural Engine
            availableMemoryGB: memoryGB,
            recommendedQuantization: isPad ? .q4_0 : .q2_K
        )
    }
    #endif

    #if os(watchOS)
    private static func detectWatchOS() -> DeviceCapabilities {
        return DeviceCapabilities(
            platform: .watchOS,
            modelIdentifier: "Apple Watch",
            supportsNeuralEngine: false,
            availableMemoryGB: 1.0, // Approximate
            recommendedQuantization: .q2_K
        )
    }
    #endif
}

// MARK: - Model Endpoint Configuration

/// Configuration for remote or local model endpoints
public struct ModelEndpoint: Codable {
    public let type: EndpointType
    public let url: String?
    public let apiKey: String?
    public let modelName: String

    public enum EndpointType: String, Codable {
        case huggingFace
        case localFile
        case remote
    }

    public init(type: EndpointType, url: String? = nil, apiKey: String? = nil, modelName: String) {
        self.type = type
        self.url = url
        self.apiKey = apiKey
        self.modelName = modelName
    }

    /// Default DOJO Field endpoint
    public static var dojoField: ModelEndpoint {
        ModelEndpoint(
            type: .huggingFace,
            url: "https://huggingface.co/DOJO/Field-MacOS-Field",
            modelName: "GPT-OSS-20B"
        )
    }
}

// MARK: - AI Service

/// Lightweight AI Service - inference client only (no bundled models)
public class AIService {
    private let endpoint: ModelEndpoint
    private let deviceCapabilities: DeviceCapabilities
    private let authorityVerifier: any CockpitAuthorityVerifying

    public init(
        endpoint: ModelEndpoint = .dojoField,
        authorityVerifier: any CockpitAuthorityVerifying =
            KingsChamberAuthorityVerifier()
    ) {
        self.endpoint = endpoint
        self.deviceCapabilities = DeviceCapabilities.detect()
        self.authorityVerifier = authorityVerifier

        print("🤖 AIService initialized")
        print("   Platform: \(deviceCapabilities.platform.rawValue)")
        print("   Model: \(deviceCapabilities.modelIdentifier)")
        print("   Neural Engine: \(deviceCapabilities.supportsNeuralEngine)")
        print("   Memory: \(String(format: "%.1f", deviceCapabilities.availableMemoryGB)) GB")
        print("   Recommended Quantization: \(deviceCapabilities.recommendedQuantization.rawValue)")
        print("   Endpoint: \(endpoint.modelName) (\(endpoint.type.rawValue))")
    }

    /// Run model synchronously
    public func runModel(input: AIModelInput) -> AIModelResult {
        print("Running AI model with input: \(input.data)")
        // TODO: Connect to actual endpoint based on configuration
        return AIModelResult(
            output: "Processed: \(input.data)",
            modelUsed: endpoint.modelName,
            deviceInfo: deviceCapabilities,
            classification: .advisory
        )
    }

    /// Run model asynchronously — calls DOJO MCP at port 7410
    @available(iOS 15.0, macOS 12.0, *)
    public func runModelAsync(input: AIModelInput) async throws -> AIModelResult {
        let client = SpinningTopClient()
        let response = try await client.sendMessage(input.data)
        return AIModelResult(
            output: response.response,
            modelUsed: response.model_used,
            deviceInfo: deviceCapabilities,
            classification: .displayOnly
        )
    }

    /// Exact scope for admitting one presentation result into a structured
    /// machine-decision boundary. Confidence is bound as metadata but never
    /// grants authority.
    public static func authorityScope(
        for result: AIModelResult,
        correlationID: UUID
    ) -> String {
        let digest = resultDigest(result)
        return [
            "ai_service_structured_result_v0",
            correlationID.uuidString.lowercased(),
            digest,
        ].joined(separator: ":")
    }

    /// Fail-closed conversion from presentation/advisory result to an
    /// authority-bearing structured result.
    ///
    /// Legacy schemas and confidence `1.0` are deliberately denied even when
    /// a proof object is supplied. This prevents the former hard-coded value
    /// from surviving as an implied authority signal.
    public func admitAuthorityBearingResult(
        _ result: AIModelResult,
        correlationID: UUID,
        authorityProof: CockpitAuthorityProof?
    ) async -> AuthorizedAIStructuredResult? {
        guard result.schemaID == AIModelResult.presentationSchemaID,
              result.confidence != 1.0 else {
            return nil
        }
        let scope = Self.authorityScope(
            for: result,
            correlationID: correlationID
        )
        guard let authorityProof,
              authorityProof.toolName == scope,
              await authorityVerifier.permits(
                  authorityProof,
                  toolName: scope,
                  correlationID: correlationID
              ) else {
            return nil
        }
        return AuthorizedAIStructuredResult(
            output: result.output,
            modelUsed: result.modelUsed,
            correlationID: correlationID,
            authorityReceiptID: authorityProof.receiptID,
            verificationID: authorityProof.verificationID,
            sourceResultDigest: Self.resultDigest(result)
        )
    }

    private static func resultDigest(_ result: AIModelResult) -> String {
        let confidence = result.confidence.map { String($0) } ?? "none"
        let canonical = [
            result.schemaID,
            result.classification.rawValue,
            result.modelUsed,
            confidence,
            result.output,
        ].joined(separator: "\u{001F}")
        return SHA256.hash(data: Data(canonical.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}

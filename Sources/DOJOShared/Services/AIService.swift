import Foundation
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

/// AI model result
public struct AIModelResult {
    public let output: String
    public let confidence: Double
    public let modelUsed: String
    public let deviceInfo: DeviceCapabilities
    
    public init(output: String, confidence: Double = 1.0, modelUsed: String = "unknown", deviceInfo: DeviceCapabilities) {
        self.output = output
        self.confidence = confidence
        self.modelUsed = modelUsed
        self.deviceInfo = deviceInfo
    }
}

// MARK: - Device Capabilities

/// Device-specific capabilities for model optimization
public struct DeviceCapabilities: Codable {
    public let platform: Platform
    public let modelIdentifier: String
    public let supportsNeuralEngine: Bool
    public let availableMemoryGB: Double
    public let recommendedQuantization: QuantizationLevel
    
    public enum Platform: String, Codable {
        case macOS
        case iOS
        case iPadOS
        case watchOS
        case unknown
    }
    
    public enum QuantizationLevel: String, Codable {
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
    
    public init(endpoint: ModelEndpoint = .dojoField) {
        self.endpoint = endpoint
        self.deviceCapabilities = DeviceCapabilities.detect()
        
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
            confidence: 0.95,
            modelUsed: endpoint.modelName,
            deviceInfo: deviceCapabilities
        )
    }
    
    /// Run model asynchronously (preferred method)
    @available(iOS 15.0, macOS 12.0, *)
    public func runModelAsync(input: AIModelInput) async throws -> AIModelResult {
        print("🔄 Running \(endpoint.modelName) on \(deviceCapabilities.platform.rawValue)")
        print("   Input: \(input.data)")
        print("   Quantization: \(deviceCapabilities.recommendedQuantization.rawValue)")
        
        // Simulate network/inference latency based on device
        let latencyMS = simulatedLatency()
        try await Task.sleep(nanoseconds: UInt64(latencyMS * 1_000_000))
        
        // TODO: Replace with actual inference call
        // - For HuggingFace: Use HTTP inference API
        // - For local: Load quantized model from bundle/documents
        
        let response = "[\(endpoint.modelName) via \(deviceCapabilities.recommendedQuantization.rawValue)]: \(input.data)"
        
        return AIModelResult(
            output: response,
            confidence: 0.95,
            modelUsed: endpoint.modelName,
            deviceInfo: deviceCapabilities
        )
    }
    
    private func simulatedLatency() -> Double {
        switch deviceCapabilities.platform {
        case .macOS:
            return 200 // Fast on desktop
        case .iOS, .iPadOS:
            return 400 // Moderate on mobile
        case .watchOS:
            return 800 // Slower on watch
        case .unknown:
            return 500
        }
    }
}

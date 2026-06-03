import Foundation

public struct PromotionGateReceipt: Codable, Equatable, Sendable {
    public let timestamp: Date
    public let identityPinPassed: Bool
    public let witnessChainPassed: Bool
    public let pazDisciplinePassed: Bool
    public let replayTestPassed: Bool
    public let degradationRulePassed: Bool
    
    public init(timestamp: Date = Date(), identityPinPassed: Bool, witnessChainPassed: Bool, pazDisciplinePassed: Bool, replayTestPassed: Bool, degradationRulePassed: Bool) {
        self.timestamp = timestamp
        self.identityPinPassed = identityPinPassed
        self.witnessChainPassed = witnessChainPassed
        self.pazDisciplinePassed = pazDisciplinePassed
        self.replayTestPassed = replayTestPassed
        self.degradationRulePassed = degradationRulePassed
    }
    
    public var isPass: Bool {
        identityPinPassed && witnessChainPassed && pazDisciplinePassed && replayTestPassed && degradationRulePassed
    }
}

public enum AuthorityLevel: Int, Codable, Equatable, Sendable {
    case level0_interfaces = 0
    case level1_notionPrimary = 1
    case level2_runtimePrimary = 2
    case level3_constitutionalPrimary = 3
}

public struct AuthorityState: Codable, Equatable, Sendable {
    public var currentLevel: AuthorityLevel
    public var consecutivePasses: Int
    public var lastReceipt: PromotionGateReceipt?
    
    public init(currentLevel: AuthorityLevel = .level1_notionPrimary, consecutivePasses: Int = 0, lastReceipt: PromotionGateReceipt? = nil) {
        self.currentLevel = currentLevel
        self.consecutivePasses = consecutivePasses
        self.lastReceipt = lastReceipt
    }
}

@MainActor
public final class AuthorityManager: ObservableObject {
    public static let shared = AuthorityManager()
    
    @Published public private(set) var state: AuthorityState
    
    private init() {
        self.state = AuthorityState()
    }
    
    public func submitReceipt(_ receipt: PromotionGateReceipt) {
        if receipt.isPass {
            state.consecutivePasses += 1
            if state.consecutivePasses >= 3 && state.currentLevel == .level1_notionPrimary {
                promote(to: .level2_runtimePrimary)
            }
        } else {
            state.consecutivePasses = 0
            if state.currentLevel == .level2_runtimePrimary || state.currentLevel == .level3_constitutionalPrimary {
                demote()
            }
        }
        state.lastReceipt = receipt
    }
    
    private func promote(to level: AuthorityLevel) {
        print("◆ AUTHORITY PROMOTION: Level \(state.currentLevel.rawValue) → Level \(level.rawValue)")
        state.currentLevel = level
    }
    
    private func demote() {
        print("◆ AUTHORITY DEMOTION: Level \(state.currentLevel.rawValue) → Level 1 (Notion Primary)")
        state.currentLevel = .level1_notionPrimary
    }
}

import Foundation

/// Protocol for messages that can be sent between modules
public protocol Message {
    var payload: String { get }
}

/// Default message implementation
public struct TextMessage: Message {
    public let payload: String
    
    public init(payload: String) {
        self.payload = payload
    }
}

/// Communication service for cross-module messaging
public class Communication {
    private static var messageQueue: [String: [Message]] = [:]
    private static let lock = NSLock()
    
    public init() {}
    
    /// Send a message to a specific module
    public static func sendMessage(to moduleName: String, message: Message) {
        lock.lock()
        defer { lock.unlock() }
        
        print("Sending message to \(moduleName): \(message.payload)")
        if messageQueue[moduleName] == nil {
            messageQueue[moduleName] = []
        }
        messageQueue[moduleName]?.append(message)
    }
    
    /// Receive messages from a specific module
    public static func receiveMessage(from moduleName: String) -> [Message] {
        lock.lock()
        defer { lock.unlock() }
        
        print("Receiving message from \(moduleName)")
        let messages = messageQueue[moduleName] ?? []
        messageQueue[moduleName] = []
        return messages
    }
}

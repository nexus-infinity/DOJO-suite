import Foundation

/// Communication service for cross-module messaging
public class Communication {
    public init() {}
    
    public static func sendMessage(to moduleName: String, message: Any) {
        print("Sending message to \(moduleName): \(message)")
        // Add logic to send message between modules
    }
    
    public static func receiveMessage(from moduleName: String) {
        print("Receiving message from \(moduleName)")
        // Add logic to receive and process messages
    }
}

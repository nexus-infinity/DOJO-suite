import Foundation

/// Dependency Injection service for decoupling modules
public class DependencyInjector {
    private static var services: [String: Any] = [:]
    
    public static func registerService(name: String, service: Any) {
        services[name] = service
    }
    
    public static func getService(name: String) -> Any? {
        return services[name]
    }
}

import Foundation

/// Dependency Injection service for decoupling modules
public class DependencyInjector {
    private static let lock = NSLock()
    private static var services: [String: Any] = [:]
    
    public static func registerService(name: String, service: Any) {
        lock.lock()
        defer { lock.unlock() }
        services[name] = service
    }
    
    public static func getService(name: String) -> Any? {
        lock.lock()
        defer { lock.unlock() }
        return services[name]
    }
    
    /// Type-safe service registration
    public static func register<T>(_ type: T.Type, service: T) {
        registerService(name: String(describing: type), service: service)
    }
    
    /// Type-safe service retrieval
    public static func get<T>(_ type: T.Type) -> T? {
        return getService(name: String(describing: type)) as? T
    }
}

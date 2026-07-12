#if !canImport(DOJOShared)
import Foundation

/// Core DOJO Shared framework (legacy fallback)
public class DOJOShared {
    public static let version = "1.0.0"

    public init() {}

    public func initialize() {
        print("DOJO Shared framework initialized - version \(Self.version)")
    }
}
#endif

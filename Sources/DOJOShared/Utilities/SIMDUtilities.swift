import Foundation

// MARK: - SIMD Utility Functions
//
// Cross-platform SIMD utilities that work on both macOS/iOS (with simd module)
// and Linux (with Swift standard library SIMD types)

#if canImport(simd)
import simd

// On Apple platforms, we can use the simd module functions directly
public func simdLength(_ vector: SIMD3<Float>) -> Float {
    simd.length(vector)
}

public func simdNormalize(_ vector: SIMD3<Float>) -> SIMD3<Float> {
    simd.normalize(vector)
}

public func simdDot(_ a: SIMD3<Float>, _ b: SIMD3<Float>) -> Float {
    simd.dot(a, b)
}

public func simdCross(_ a: SIMD3<Float>, _ b: SIMD3<Float>) -> SIMD3<Float> {
    simd.cross(a, b)
}

#else

// On Linux and other platforms, implement SIMD functions manually
public func simdLength(_ vector: SIMD3<Float>) -> Float {
    sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
}

public func simdNormalize(_ vector: SIMD3<Float>) -> SIMD3<Float> {
    let len = simdLength(vector)
    guard len > 0 else { return SIMD3<Float>(0, 0, 0) }
    return vector / len
}

public func simdDot(_ a: SIMD3<Float>, _ b: SIMD3<Float>) -> Float {
    a.x * b.x + a.y * b.y + a.z * b.z
}

public func simdCross(_ a: SIMD3<Float>, _ b: SIMD3<Float>) -> SIMD3<Float> {
    SIMD3<Float>(
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x
    )
}

#endif

// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DOJO-suite",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // Library product for shared geometry, particle engine, and OOO framework
        .library(
            name: "DOJOShared",
            targets: ["DOJOShared"]
        ),
        // Note: iOS/macOS executable apps are only buildable on Apple platforms
        // They are excluded from this manifest to support Linux builds
        // Use Xcode or xcodebuild directly on macOS to build the apps
    ],
    dependencies: [
        // No external dependencies - keeping it self-contained
    ],
    targets: [
        // Shared library target
        .target(
            name: "DOJOShared",
            dependencies: [],
            path: "Sources/DOJOShared"
        ),
        
        // Test target
        .testTarget(
            name: "DOJOSharedTests",
            dependencies: ["DOJOShared"],
            path: "Tests/DOJOSharedTests"
        )
    ]
)


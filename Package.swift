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
        )
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

// Only build iOS/macOS apps on Apple platforms
#if os(macOS) || os(iOS)
package.products.append(contentsOf: [
    .executable(name: "DOJOiOSApp", targets: ["DOJOiOSApp"]),
    .executable(name: "DOJOMacApp", targets: ["DOJOMacApp"])
])

package.targets.append(contentsOf: [
    .executableTarget(
        name: "DOJOiOSApp",
        dependencies: ["DOJOShared"],
        path: "Sources/DOJOiOSApp"
    ),
    .executableTarget(
        name: "DOJOMacApp",
        dependencies: ["DOJOShared"],
        path: "Sources/DOJOMacApp"
    )
])
#endif


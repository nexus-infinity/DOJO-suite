// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DOJO-suite",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        // Library product for shared geometry, particle engine, and OOO framework
        .library(
            name: "DOJOShared",
            targets: ["DOJOShared"]
        ),
        // UI library product for SwiftUI views and previews
        .library(
            name: "DOJOUI",
            targets: ["DOJOUI"]
        ),
        // Executable products for the 4 Sacred Trident apps
        .executable(name: "DOJOApp", targets: ["DOJOApp"]),
        .executable(name: "ArkadašApp", targets: ["ArkadašApp"]),
        .executable(name: "OB1LinkApp", targets: ["OB1LinkApp"]),
        .executable(name: "DojoLinkApp", targets: ["DojoLinkApp"]),
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
        // UI library target to host SwiftUI views and previews
        .target(
            name: "DOJOUI",
            dependencies: ["DOJOShared"],
            path: "Sources/DOJOUI"
        ),
        
        // ◼︎ DOJO.app (741 Hz) - Manifestation orchestrator
        .executableTarget(
            name: "DOJOApp",
            dependencies: ["DOJOShared", "DOJOUI"],
            path: "Sources/DOJOApp"
        ),
        
        // 🎭 Arkadaš.app (852 Hz) - 27-agent Grand Gallery
        .executableTarget(
            name: "ArkadašApp",
            dependencies: ["DOJOShared"],
            path: "Sources/ArkadašApp"
        ),
        
        // ● OB1Link.app (963 Hz) - Observer consciousness
        .executableTarget(
            name: "OB1LinkApp",
            dependencies: ["DOJOShared"],
            path: "Sources/OB1LinkApp"
        ),
        
        // ◆ DojoLink.app (717 Hz) - Mobile field interface
        .executableTarget(
            name: "DojoLinkApp",
            dependencies: ["DOJOShared"],
            path: "Sources/DojoLinkApp"
        ),
        
        // Test target
        .testTarget(
            name: "DOJOSharedTests",
            dependencies: ["DOJOShared"],
            path: "Tests/DOJOSharedTests"
        )
    ]
)

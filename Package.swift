// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DOJO-suite",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(name: "DOJOShared", targets: ["DOJOShared"]),
        .library(name: "DOJOUI", targets: ["DOJOUI"]),
        .library(name: "DOJOPersistence", targets: ["DOJOPersistence"]),
        .library(name: "DOJOTransport", targets: ["DOJOTransport"]),
        .executable(name: "DOJOApp", targets: ["DOJOApp"]),
        .executable(name: "ArkadasApp", targets: ["ArkadasApp"]),
        .executable(name: "OB1LinkApp", targets: ["OB1LinkApp"]),
        .executable(name: "DojoLinkApp", targets: ["DojoLinkApp"]),
        .executable(name: "DOJOiOSApp", targets: ["DOJOiOSApp"]),
        .executable(name: "AKRONMac", targets: ["AKRONMac"]),
        .executable(name: "DOJOWatchApp", targets: ["DOJOWatchApp"]),
        .executable(name: "TodayKeep", targets: ["TodayKeep"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "DOJOShared", dependencies: [], path: "Sources/DOJOShared"),
        .target(name: "DOJOUI", dependencies: ["DOJOShared"], path: "Sources/DOJOUI", exclude: [
            "DesignSystem/CRYPTOGRAPHIC_SIGNING_GUIDE.md",
            "DesignSystem/DOCUMENT_INTAKE_CHECKLIST.md",
            "DesignSystem/DOJO_SUITE_CANONICAL_CONTRACT.md",
            "DesignSystem/FORMAL_REPORT_TEMPLATE.md",
            "DesignSystem/GEOMETRIC_HARDENING_SUMMARY.md",
            "DesignSystem/REGULATOR_FILING_TRACKER.md",
            "DesignSystem/SERVICE_AGREEMENT_TEMPLATE.md",
            "DesignSystem/TEMPLATE_SUITE_SUMMARY.md",
        ]),
        .executableTarget(
            name: "DOJOApp",
            dependencies: ["DOJOShared", "DOJOUI"],
            path: "Sources/DOJOApp",
            exclude: ["Info.plist"]
        ),
        .executableTarget(name: "ArkadasApp", dependencies: ["DOJOShared", "DOJOUI"], path: "Sources/ArkadasApp"),
        .executableTarget(name: "OB1LinkApp", dependencies: ["DOJOShared", "DOJOUI"], path: "Sources/OB1LinkApp"),
        .executableTarget(name: "DojoLinkApp", dependencies: ["DOJOShared", "DOJOUI"], path: "Sources/DojoLinkApp"),
        .target(name: "DOJOPersistence", dependencies: ["DOJOShared"], path: "Sources/DOJOPersistence"),
        .target(name: "DOJOTransport", dependencies: ["DOJOShared"], path: "Sources/DOJOTransport"),
        .executableTarget(name: "DOJOiOSApp", dependencies: ["DOJOPersistence", "DOJOTransport", "DOJOShared", "DOJOUI"], path: "Sources/DOJOiOSApp", exclude: ["Info.plist"], resources: [.process("Assets.xcassets")]),
        .executableTarget(name: "AKRONMac", dependencies: ["DOJOPersistence", "DOJOShared"], path: "Sources/AKRONMac"),
        .executableTarget(name: "DOJOWatchApp", dependencies: ["DOJOShared", "DOJOUI"], path: "Sources/DOJOWatchApp"),
        .executableTarget(name: "TodayKeep", dependencies: ["DOJOShared"], path: "Sources/TodayKeep"),
        .testTarget(name: "DOJOSharedTests", dependencies: ["DOJOShared", "DOJOUI", "DOJOPersistence"], path: "Tests/DOJOSharedTests")
    ]
)

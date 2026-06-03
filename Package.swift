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
        .library(name: "FieldKit", targets: ["FieldKit"]),
        .executable(name: "DOJOApp", targets: ["DOJOApp"]),
        .executable(name: "ArkadašApp", targets: ["ArkadašApp"]),
        .executable(name: "OB1LinkApp", targets: ["OB1LinkApp"]),
        .executable(name: "DojoLinkApp", targets: ["DojoLinkApp"]),
        .executable(name: "DOJOiOSApp", targets: ["DOJOiOSApp"]),
        .executable(name: "AKRONMac", targets: ["AKRONMac"]),
        .executable(name: "DOJOWatchApp", targets: ["DOJOWatchApp"]),
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
        .executableTarget(name: "DOJOApp", dependencies: ["DOJOShared", "DOJOUI"], path: "Sources/DOJOApp"),
        .executableTarget(name: "ArkadašApp", dependencies: ["DOJOShared", "DOJOUI"], path: "Sources/ArkadašApp"),
        .executableTarget(name: "OB1LinkApp", dependencies: ["DOJOShared", "DOJOUI"], path: "Sources/OB1LinkApp"),
        .executableTarget(name: "DojoLinkApp", dependencies: ["DOJOShared", "DOJOUI"], path: "Sources/DojoLinkApp"),
        .target(name: "FieldKit", dependencies: [], path: "Sources/FieldKit"),
        .executableTarget(name: "DOJOiOSApp", dependencies: ["FieldKit", "DOJOShared"], path: "Sources/DOJOiOSApp"),
        .executableTarget(name: "AKRONMac", dependencies: ["FieldKit"], path: "Sources/AKRONMac"),
        .executableTarget(name: "DOJOWatchApp", dependencies: ["DOJOShared", "DOJOUI"], path: "Sources/DOJOWatchApp"),
        .testTarget(name: "DOJOSharedTests", dependencies: ["DOJOShared", "DOJOUI", "FieldKit"], path: "Tests/DOJOSharedTests")
    ]
)

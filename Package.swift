// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReplicantSwift",
    platforms: [
        .iOS(.v15),
        .macOS(.v14),
    ],
    products: [.library(name: "ReplicantSwift", targets: ["ReplicantSwift"])],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto", from: "3.2.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.5.3"),

        .package(url: "https://github.com/OperatorFoundation/Datable", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Gardener", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Ghostwriter", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/KeychainTypes", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Monolith", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/ShadowSwift", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/SwiftHexTools", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/SwiftQueue", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/TransmissionAsync", branch: "main"),
    ],
    targets: [
        .target(
            name: "ReplicantSwift",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Logging", package: "swift-log"),
                "Datable",
                "Gardener",
                "Ghostwriter",
                "KeychainTypes",
                "Monolith",
                "ShadowSwift",
                "SwiftHexTools",
                "SwiftQueue",
                "TransmissionAsync"
            ]
        ),
        .testTarget(
            name: "ReplicantSwiftTests",
            dependencies: ["ReplicantSwift"]),
    ],
    swiftLanguageVersions: [.v5]
)

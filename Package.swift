// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReplicantSwift",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
    ],
    products: [.library(name: "ReplicantSwift", targets: ["ReplicantSwift"])],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto", from: "3.3.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.5.3"),

        .package(url: "https://github.com/OperatorFoundation/Datable", from: "4.0.1"),
        .package(url: "https://github.com/OperatorFoundation/Gardener", from: "0.1.2"),
        .package(url: "https://github.com/OperatorFoundation/Ghostwriter", from: "1.0.1"),
        .package(url: "https://github.com/OperatorFoundation/KeychainTypes", from: "1.0.2"),
        .package(url: "https://github.com/OperatorFoundation/Monolith", from: "1.0.6"),
        .package(url: "https://github.com/OperatorFoundation/ShadowSwift", from: "5.0.3"),
        .package(url: "https://github.com/OperatorFoundation/SwiftHexTools", from: "1.2.6"),
        .package(url: "https://github.com/OperatorFoundation/SwiftQueue", from: "0.1.3"),
        .package(url: "https://github.com/OperatorFoundation/TransmissionAsync", from: "0.1.5"),
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

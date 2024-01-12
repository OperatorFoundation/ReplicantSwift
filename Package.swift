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
        .package(url: "https://github.com/apple/swift-crypto", from: "3.2.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.5.3"),

        .package(url: "https://github.com/OperatorFoundation/Datable", from: "4.0.0"),
        .package(url: "https://github.com/OperatorFoundation/Gardener", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/Ghostwriter", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/KeychainTypes", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/Monolith", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/Net", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/ShadowSwift", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/Song", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/Spacetime", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/SwiftHexTools", from: "1.2.6"),
        .package(url: "https://github.com/OperatorFoundation/SwiftQueue", from: "0.1.2"),
        .package(url: "https://github.com/OperatorFoundation/Transmission", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/TransmissionAsync", branch: "release"),
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
                "Net",
                "ShadowSwift",
                "Song",
                .product(name: "Simulation", package: "Spacetime"),
                .product(name: "Spacetime", package: "Spacetime"),
                .product(name: "Universe", package: "Spacetime"),
                "SwiftHexTools",
                "SwiftQueue",
                "Transmission",
                "TransmissionAsync"
            ]
        ),
        .testTarget(
            name: "ReplicantSwiftTests",
            dependencies: ["ReplicantSwift"]),
    ],
    swiftLanguageVersions: [.v5]
)

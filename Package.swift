// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReplicantSwift",
    platforms: [.macOS(.v10_15)],
    products: [.library(name: "ReplicantSwift", targets: ["ReplicantSwift"])],
    dependencies: [
        .package(url: "https://github.com/OperatorFoundation/Net.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-crypto.git",
                 from: "2.0.0"),
        .package(url: "https://github.com/OperatorFoundation/Keychain.git",
                 from: "1.0.0"),
        .package(url: "https://github.com/OperatorFoundation/Song.git",
                 from: "0.2.3"),
        .package(url: "https://github.com/apple/swift-log.git",
                 from: "1.4.2"),
        .package(url: "https://github.com/OperatorFoundation/Monolith.git",
                 from: "1.0.4"),
        .package(url: "https://github.com/OperatorFoundation/Datable.git",
                 from: "3.1.2"),
        .package(url: "https://github.com/OperatorFoundation/Transmission.git", from: "1.0.4"),
        .package(url: "https://github.com/OperatorFoundation/SwiftQueue.git",
                 from: "0.1.2")
    ],
    targets: [
        .target(
            name: "ReplicantSwift",
            dependencies: [
                "Datable",
                "Monolith",
                "Song",
                "SwiftQueue",
                "Transmission",
                "Net",
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Keychain", package: "Keychain"),
            ]
        ),
        .testTarget(
            name: "ReplicantSwiftTests",
            dependencies: ["ReplicantSwift"]),
    ],
    swiftLanguageVersions: [.v5]
)

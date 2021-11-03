// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(iOS) || os(macOS) || os(watchOS) || os(tvOS)
let package = Package(
    name: "ReplicantSwift",
    platforms: [.macOS(.v10_15)],
    products: [.library(name: "ReplicantSwift", targets: ["ReplicantSwift"])],
    dependencies: [
        .package(url: "https://github.com/OperatorFoundation/Keychain.git",
                 from: "0.1.2"),
        .package(url: "https://github.com/OperatorFoundation/Song.git",
                 from: "0.1.7"),
        .package(url: "https://github.com/apple/swift-log.git",
                 from: "1.4.2"),
        .package(url: "https://github.com/OperatorFoundation/Monolith.git",
                 from: "1.0.3"),
        .package(url: "https://github.com/OperatorFoundation/Datable.git",
                 from: "3.1.1"),
        .package(url: "https://github.com/OperatorFoundation/Transmission.git", from: "0.6.0"),
        .package(url: "https://github.com/OperatorFoundation/SwiftQueue.git",
                 from: "0.1.1")
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
#elseif os(Linux)
let package = Package(
    name: "ReplicantSwift",
    products: [.library(name: "ReplicantSwift", targets: ["ReplicantSwift"])],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git",
                 from: "1.1.2"),
        .package(url: "https://github.com/OperatorFoundation/KeychainLinux.git",
                 from: "0.1.1"),
        .package(url: "https://github.com/OperatorFoundation/Song.git",
                 from: "0.2.1"),
        .package(url: "https://github.com/apple/swift-log.git",
                 from: "1.4.2"),
        .package(url: "https://github.com/OperatorFoundation/Monolith.git",
                 from: "1.0.2"),
        .package(url: "https://github.com/OperatorFoundation/Datable.git",
                 from: "3.0.6"),
        .package(url: "https://github.com/OperatorFoundation/Transmission.git", from: "0.6.0"),
        .package(url: "https://github.com/OperatorFoundation/SwiftQueue.git",
                 from: "0.1.0")
    ],
    targets: [
        .target(
            name: "ReplicantSwift",
            dependencies: [
                "Datable",
                "Monolith",
                "Song",
                "SwiftQueue",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "KeychainLinux", package: "KeychainLinux"),
                .product(name: "Crypto", package: "swift-crypto")
            ]),
        .testTarget(
            name: "ReplicantSwiftTests",
            dependencies: ["ReplicantSwift"]),
    ],
    swiftLanguageVersions: [.v5])
#endif

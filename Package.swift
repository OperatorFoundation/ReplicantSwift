// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReplicantSwift",
    platforms: [.macOS(.v10_15)],
    products: [.library(name: "ReplicantSwift", targets: ["ReplicantSwift"])],
    dependencies: [
        .package(url: "https://github.com/OperatorFoundation/Net.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-crypto.git",
                 from: "2.0.0"),
        .package(url: "https://github.com/OperatorFoundation/Keychain.git",
                 branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Song.git",
                 branch: "main"),
        .package(url: "https://github.com/apple/swift-log.git",
                 from: "1.4.2"),
        .package(url: "https://github.com/OperatorFoundation/Monolith.git",
                 branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Datable.git",
                 branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Transmission.git", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/SwiftQueue.git",
                 branch: "main")
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
                "Keychain",
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .testTarget(
            name: "ReplicantSwiftTests",
            dependencies: ["ReplicantSwift"]),
    ],
    swiftLanguageVersions: [.v5]
)

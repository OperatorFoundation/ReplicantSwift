// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReplicantSwift",
    platforms: [
       .macOS(.v11)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ReplicantSwift",
            targets: ["ReplicantSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-crypto.git", from: "1.1.2"),
        .package(url: "https://github.com/OperatorFoundation/Keychain.git", from: "0.1.2"),
        .package(url: "https://github.com/OperatorFoundation/KeychainLinux.git", from: "0.1.1"),
        .package(url: "https://github.com/OperatorFoundation/Song.git", from: "0.1.1"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
        .package(url: "https://github.com/OperatorFoundation/Monolith.git", from: "1.0.2"),
        .package(url: "https://github.com/OperatorFoundation/Datable.git", from: "3.0.4"),
        .package(url: "https://github.com/OperatorFoundation/Transport.git", from: "2.3.5"),
        .package(url: "https://github.com/OperatorFoundation/SwiftQueue.git", from: "0.1.0")
],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ReplicantSwift",
            dependencies: [
                "Monolith", "Datable", "Transport", "Song", "SwiftQueue",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Keychain", package: "Keychain", condition: .when(platforms: [.iOS, .macOS, .watchOS, .tvOS])),
                .product(name: "KeychainLinux", package: "KeychainLinux", condition: .when(platforms: [.linux])),
                .product(name: "Crypto", package: "swift-crypto", condition: .when(platforms: [.linux]))
            ]
        ),
        .testTarget(
            name: "ReplicantSwiftTests",
            dependencies: ["ReplicantSwift"]),
    ],
    swiftLanguageVersions: [.v5]
)

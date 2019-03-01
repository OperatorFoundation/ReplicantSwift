// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReplicantSwift",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ReplicantSwift",
            targets: ["ReplicantSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/OperatorFoundation/Datable.git", from: "1.0.5"),
        .package(url: "https://github.com/OperatorFoundation/Transport.git", from: "0.1.1"),
        .package(url: "https://github.com/OperatorFoundation/SwiftQueue.git", from: "0.0.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ReplicantSwift",
            dependencies: ["Datable", "Transport", "SwiftQueue"]),
        .testTarget(
            name: "ReplicantSwiftTests",
            dependencies: ["ReplicantSwift"]),
    ]
)

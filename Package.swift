// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RHStackCard",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RHStackCard",
            targets: ["RHStackCard"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/HsinChungHan/RHNetworkAPI.git",
            branch: "main"),
        .package(
            url: "https://github.com/HsinChungHan/RHCacheStoreAPI.git",
            branch: "main"),
        .package(
            url: "https://github.com/HsinChungHan/RHUIComponent.git",
            branch: "main"),
        .package(
            url: "https://github.com/HsinChungHan/RHInterface.git",
            branch: "main"),
        .package(
            url: "https://github.com/SnapKit/SnapKit",
            branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RHStackCard",
            dependencies: ["RHNetworkAPI", "RHCacheStoreAPI", "RHUIComponent", "RHInterface", "SnapKit"]),
        .testTarget(
            name: "RHStackCardTests",
            dependencies: ["RHStackCard"]),
    ]
)

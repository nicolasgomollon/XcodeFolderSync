// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XcodeFolderSync",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "xcode-folder-sync", targets: ["XcodeFolderSync"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.1"),
        .package(url: "https://github.com/tuist/XcodeProj.git", from: "9.4.2"),
    ],
    targets: [
        .executableTarget(
            name: "XcodeFolderSync",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "PathKit", package: "PathKit"),
                .product(name: "XcodeProj", package: "XcodeProj"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]),
    ],
    swiftLanguageModes: [
        .v6,
    ]
)

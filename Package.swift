// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MediaPipeline",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "MediaPipeline",
            targets: ["MediaPipeline"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "MediaPipeline",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms")
            ]
        ),
        .testTarget(
            name: "MediaPipelineTests",
            dependencies: ["MediaPipeline"],
            resources: [
                .copy("Resources/ultraHD8K.jpg"),
                .copy("Resources/ultraHD8K.mp4"),
                .copy("Resources/vga.mp4"),
                .copy("Resources/square.mp4"),
            ]
        ),
    ]
)

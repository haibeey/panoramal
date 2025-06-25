// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "panoramaI",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "panoramaI",
            targets: ["panoramaI"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "panoramaI",
            dependencies: [],
            path: "Sources/panoramaI",
            resources: [
                .copy("Shader.txt")
            ]
        ),
        .testTarget(
            name: "panoramaITests",
            dependencies: ["panoramaI"]),
    ]
)

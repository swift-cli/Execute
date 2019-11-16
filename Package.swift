// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Execute",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "Execute",
            targets: ["Execute"]
        )
    ],
    targets: [
        .target(
            name: "Execute"
        ),
        .testTarget(
            name: "ExecuteTests",
            dependencies: ["Execute"]
        )
    ]
)

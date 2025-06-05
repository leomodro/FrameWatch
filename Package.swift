// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FrameWatch",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "FrameWatch",
            targets: ["FrameWatch"]),
    ],
    targets: [
        .target(
            name: "FrameWatch"),
        .testTarget(
            name: "FrameWatchTests",
            dependencies: ["FrameWatch"]
        ),
    ]
)

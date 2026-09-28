// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "TouchVisualization",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "TouchVisualization", targets: ["TouchVisualization"])
    ],
    targets: [
        .target(name: "TouchVisualization"),
        .testTarget(
            name: "TouchVisualizationTests",
            dependencies: ["TouchVisualization"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

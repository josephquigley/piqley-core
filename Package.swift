// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PiqleyCore",
    products: [
        .library(
            name: "PiqleyCore",
            targets: ["PiqleyCore"]
        ),
    ],
    targets: [
        .target(
            name: "PiqleyCore"
        ),
        .testTarget(
            name: "PiqleyCoreTests",
            dependencies: ["PiqleyCore"]
        ),
    ]
)

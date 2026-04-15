// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CrossTrack",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "CrossTrack", targets: ["CrossTrack"])
    ],
    targets: [
        .target(
            name: "CrossTrack",
            path: "Sources/CrossTrack"
        ),
        .testTarget(
            name: "CrossTrackTests",
            dependencies: ["CrossTrack"],
            path: "Tests/CrossTrackTests"
        )
    ]
)

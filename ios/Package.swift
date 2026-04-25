// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(name: "MyApp", targets: ["MyApp"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MyApp",
            path: "App/Sources"
        ),
        .testTarget(
            name: "MyAppTests",
            dependencies: ["MyApp"],
            path: "App/Tests"
        ),
    ]
)

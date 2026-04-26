// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "__APP_NAME__",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(name: "__APP_NAME__", targets: ["__APP_NAME__"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "__APP_NAME__",
            path: "App/Sources"
        ),
        .testTarget(
            name: "__APP_NAME__Tests",
            dependencies: ["__APP_NAME__"],
            path: "App/Tests"
        ),
    ]
)

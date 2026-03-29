// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PermissionKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "PermissionKit",
            targets: ["PermissionKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PermissionKit",
            dependencies: [],
            path: "Sources/PermissionKit"),
        .testTarget(
            name: "PermissionKitTests",
            dependencies: ["PermissionKit"],
            path: "Tests/PermissionKitTests"),
    ]
)

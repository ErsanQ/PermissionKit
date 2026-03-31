// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PermissionKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
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

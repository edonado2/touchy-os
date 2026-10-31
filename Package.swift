// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TouchyOS",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "TouchyOS", targets: ["TouchyOS"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "TouchyOS",
            path: "Sources/TouchyOS",
            exclude: ["Resources/Info.plist", "Resources/TouchyOS.entitlements"]
        ),
        .testTarget(
            name: "TouchyOSTests",
            dependencies: ["TouchyOS"],
            path: "Tests/TouchyOSTests"
        )
    ]
)
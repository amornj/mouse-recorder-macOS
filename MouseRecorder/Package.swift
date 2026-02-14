// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MouseRecorder",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey.git", from: "0.2.1"),
    ],
    targets: [
        .executableTarget(
            name: "MouseRecorder",
            dependencies: ["HotKey"],
            path: "MouseRecorder",
            exclude: ["Info.plist", "MouseRecorder.entitlements"]
        ),
    ]
)

// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Judo",
    platforms: [.iOS(.v14), .macOS(.v13), .macCatalyst(.v14), .visionOS(.v1)],
    products: [
        .library(name: "Judo", type: .static, targets: ["Judo"]),
        .library(name: "JudoDocument", type: .static, targets: ["JudoDocument"]),
        .library(name: "XCAssetsKit", type: .static, targets: ["XCAssetsKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.18")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.1.0"))
    ],
    targets: [
        .target(
            name: "Judo",
            dependencies: [
                .target(name: "JudoRenderer", condition: .when(platforms: [.iOS, .visionOS]))
            ]
        ),
        .target(
            name: "JudoRenderer",
            dependencies: [
                .target(name: "JudoDocument"),
                .target(name: "Backport"),
                .target(name: "XCAssetsKit"),
                .target(name: "JudoExpressions")
            ],
            resources: [
                .copy("Assets/Logo.png")
            ]
        ),
        .target(
            name: "JudoDocument",
            dependencies: [
                "ZIPFoundation",
                .target(name: "XCAssetsKit"),
                .target(name: "JudoExpressions"),
                .product(name: "Collections", package: "swift-collections"),
            ]
        ),
        .target(
            name: "JudoExpressions"
        ),
        .target(
            name: "Backport"
        ),
        .target(
            name: "XCAssetsKit"
        ),
        .testTarget(
            name: "ExpressionsTests",
            dependencies: ["JudoExpressions"]
        ),
    ]
)

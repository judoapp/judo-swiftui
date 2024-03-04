// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Judo",
    platforms: [.iOS(.v14), .macOS(.v13), .macCatalyst(.v14), .visionOS(.v1)],
    products: [
        .library(name: "Judo", type: .static, targets: ["Judo"]),
        .library(name: "JudoDocument", type: .static, targets: ["JudoDocument"]),
        .library(name: "JudoBackport", type: .static, targets: ["Backport"]),
        .library(name: "XCAssetsKit", type: .static, targets: ["XCAssetsKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.18")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.4")),
        .package(name: "JudoExpressions", path: "JudoExpressions")
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
                .product(name: "JudoExpressions", package: "JudoExpressions")
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
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "JudoExpressions", package: "JudoExpressions")
            ]
        ),
        .target(
            name: "Backport"
        ),
        .target(
            name: "XCAssetsKit"
        )
    ]
)

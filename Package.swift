// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Judo",
    platforms: [.iOS(.v14), .macOS(.v13)],
    products: [
        .library(name: "Judo", type: .static, targets: ["Judo"]),
        .library(name: "JudoModel", type: .static, targets: ["JudoModel"]),
        .library(name: "JudoBackport", type: .static, targets: ["Backport"])
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.16")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.4")),
        .package(url: "https://github.com/siteline/SwiftUI-Introspect.git", .upToNextMajor(from: "0.2.3"))
    ],
    targets: [
        .target(
            name: "Judo",
            dependencies: [
                .target(name: "JudoRenderer", condition: .when(platforms: [.iOS]))
            ]
        ),
        .target(
            name: "JudoRenderer",
            dependencies: [
                .target(name: "JudoModel"),
                .target(name: "Backport"),
                .target(name: "XCAssetsKit"),
                .product(name: "Introspect", package: "SwiftUI-Introspect")
            ],
            resources: [
                .copy("Assets/404-dark.png"),
                .copy("Assets/404-dark@2x.png"),
                .copy("Assets/404.png"),
                .copy("Assets/404@2x.png")
            ]
        ),
        .target(
            name: "JudoModel",
            dependencies: [
                "JudoModelV2"
            ],
            exclude: ["CurrentModel.stencil", "README.md"]
        ),
        .target(
            name: "JudoModelV1",
            dependencies: [
                "ZIPFoundation",
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
        .target(
            name: "JudoModelV2",
            dependencies: [
                .target(name: "JudoModelV1"),
                "ZIPFoundation",
                .target(name: "XCAssetsKit"),
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
        .target(
            name: "Backport"
        ),
        .target(
            name: "XCAssetsKit"
        ),
        .testTarget(
            name: "JudoModelV1Tests",
            dependencies: ["JudoModelV1"]
        ),
        .testTarget(
            name: "JudoModelV2Tests",
            dependencies: ["JudoModelV2"]
        )
    ]
)

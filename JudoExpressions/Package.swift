// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "JudoExpressions",
    platforms: [.macOS(.v12), .iOS(.v14), .visionOS(.v1)],
    products: [
        .library(
            name: "JudoExpressions",
            targets: ["JudoExpressions"]
        ),
    ],
    targets: [
        .target(
            name: "JudoExpressions",
            dependencies: ["Lexer", "Parser", "Interpreter"]
        ),
        .target(
            name: "Lexer"
        ),
        .target(
            name: "Parser",
            dependencies: ["Lexer"]
        ),
        .target(
            name: "Interpreter",
            dependencies: ["Lexer", "Parser"]
        ),
        .testTarget(
            name: "Tests",
            dependencies: ["Lexer", "Parser", "Interpreter"]),
    ]
)

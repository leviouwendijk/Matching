// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Matching",
    // platforms: [
    //     .macOS(.v13)
    // ],
    products: [
        .library(
            name: "Matching",
            targets: ["Matching"]
        ),
        .executable(
            name: "t_matching",
            targets: ["MatchingTesting"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/leviouwendijk/Tokens.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Position.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Testing.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "Matching",
            dependencies: [
                .product(name: "Tokens", package: "Tokens"),
                .product(name: "Position", package: "Position"),
            ],
        ),
        .executableTarget(
            name: "MatchingTesting",
            dependencies: [
                "Matching",
                .product(name: "Tokens", package: "Tokens"),
                .product(name: "Testing", package: "Testing"),
            ],
            path: "Testing/MatchingTesting"
        ),
    ]
)

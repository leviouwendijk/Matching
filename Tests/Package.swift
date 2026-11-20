// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MatchingTests",
    // platforms: [
    //     .macOS(.v13)
    // ],
    products: [
        .executable(
            name: "t_matching",
            targets: ["MatchingTesting"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/leviouwendijk/Tokens.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Testing.git", branch: "master"),
        .package(path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "MatchingTesting",
            dependencies: [
                .product(name: "Matching", package: "Matching"),
                .product(name: "Tokens", package: "Tokens"),
                .product(name: "Testing", package: "Testing"),
            ]
        ),
    ]
)

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
    ],
    dependencies: [
        .package(url: "https://github.com/leviouwendijk/Tokens.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Position.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "Matching",
            dependencies: [
                .product(name: "Tokens", package: "Tokens"),
                .product(name: "Position", package: "Position"),
            ],
        ),
    ]
)

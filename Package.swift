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
        // .executable(
        //     name: "matchtest",
        //     targets: ["MatchingTestFlows"]
        // ),
    ],
    dependencies: [
        .package(url: "https://github.com/leviouwendijk/Tokens.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Position.git", branch: "master"),
        // .package(url: "https://github.com/leviouwendijk/TestFlows.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "Matching",
            dependencies: [
                .product(name: "Tokens", package: "Tokens"),
                .product(name: "Position", package: "Position"),
            ],
        ),
        // .executableTarget(
        //     name: "MatchingTestFlows",
        //     dependencies: [
        //         "Matching",
        //         .product(name: "Tokens", package: "Tokens"),
        //         .product(name: "TestFlows", package: "TestFlows"),
        //     ]
        // ),
    ]
)

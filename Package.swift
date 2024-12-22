// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Networking",
            targets: ["Networking"]
        ),
        .library(
            name: "NetworkingInterfaces",
            targets: ["NetworkingInterfaces"]
        )
    ],
    targets: [
        .target(
            name: "Networking",
            dependencies: [
                .target(name: "NetworkingInterfaces")
            ]
        ),
        .target(name: "NetworkingInterfaces"),
        .testTarget(
            name: "NetworkingTests",
            dependencies: [
                .target(name: "Networking"),
                .target(name: "NetworkingInterfaces")
            ]
        )
    ]
)

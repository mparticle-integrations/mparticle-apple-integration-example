// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mParticle-Integration-Example",
    platforms: [ .iOS(.v11), .tvOS(.v11) ], 
    products: [
        .library(
            name: "mParticle-Integration-Example",
            targets: ["mParticle-Integration-Example"]),
    ],
    dependencies: [
      .package(name: "mParticle-Apple-SDK",
               url: "https://github.com/mParticle/mparticle-apple-sdk",
               .upToNextMajor(from: "8.0.0")),
    ],
    targets: [
        .target(
            name: "mParticle-Integration-Example",
            dependencies: [
              .product(name: "mParticle-Apple-SDK", package: "mParticle-Apple-SDK"),
            ],
            path: "mParticle-Example",
            publicHeadersPath: "."
        ),
    ]
)

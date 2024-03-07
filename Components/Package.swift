// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Components",
    platforms: [.macOS(.v11)],
    products: [
        .library(
            name: "ClassDumperCore",
            targets: ["ClassDumperCore"]
        ),
        .library(
            name: "ClassDumperUI",
            targets: ["ClassDumperUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/ExceptionCatcher", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/SnapKit/SnapKit", .upToNextMajor(from: "5.7.1")),
        .package(url: "https://github.com/Mx-Iris/UIFoundation", branch: "main"),
        .package(url: "https://github.com/Mx-Iris/FrameworkToolbox", branch: "main"),
        .package(url: "https://github.com/MxIris-Reverse-Engineering-Forks/ClassDump", branch: "main"),
        .package(url: "https://github.com/Mx-Iris/SFSymbol", branch: "main"),
    ],
    targets: [
        .target(
            name: "ClassDumperCore",
            dependencies: [
                .product(name: "ClassDump", package: "ClassDump"),
                .product(name: "ExceptionCatcher", package: "ExceptionCatcher"),
                .product(name: "FrameworkToolbox", package: "FrameworkToolbox"),
                .product(name: "FoundationToolbox", package: "FrameworkToolbox"),
            ]
        ),
        .target(
            name: "ClassDumperUI",
            dependencies: [
                "ClassDumperCore",
                "ApplicationLaunchers",
                .product(name: "FrameworkToolbox", package: "FrameworkToolbox"),
                .product(name: "FoundationToolbox", package: "FrameworkToolbox"),
                .product(name: "UIFoundation", package: "UIFoundation"),
                .product(name: "UIFoundationToolbox", package: "UIFoundation"),
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "SFSymbol", package: "SFSymbol")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "ApplicationLaunchers"
        )
    ]
)

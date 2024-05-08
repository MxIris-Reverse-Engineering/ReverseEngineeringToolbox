// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Components",
    platforms: [.macOS(.v12)],
    products: [
        .library(
            name: "ClassDumperCore",
            targets: ["ClassDumperCore"]
        ),
        .library(
            name: "ClassDumperUI",
            targets: ["ClassDumperUI"]
        ),
        .library(
            name: "ApplicationLaunchers",
            targets: ["ApplicationLaunchers"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/ExceptionCatcher.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.7.1")),
        .package(url: "https://github.com/Mx-Iris/UIFoundation.git", branch: "main"),
        .package(url: "https://github.com/Mx-Iris/FrameworkToolbox.git", branch: "main"),
        .package(url: "https://github.com/MxIris-Reverse-Engineering-Forks/ClassDump.git", branch: "main"),
        .package(url: "https://github.com/MxIris-Reverse-Engineering-Forks/ClassDumpDyld.git", branch: "main"),
        .package(url: "https://github.com/Mx-Iris/SFSymbol.git", branch: "main"),
        .package(url: "https://github.com/flocked/AdvancedCollectionTableView.git", branch: "main"),
        .package(url: "https://github.com/freysie/ide-icons.git", branch: "main"),
        .package(url: "https://github.com/j-f1/MenuBuilder.git", branch: "main"),
        .package(url: "https://github.com/zenangst/Apps.git", branch: "main"),
        .package(url: "https://github.com/leptos-null/ClassDumpRuntime.git", branch: "master"),
        .package(url: "https://github.com/Zollerboy1/SwiftCommand", branch: "main"),
    ],
    targets: [
        .target(
            name: "ClassDumperCore",
            dependencies: [
                "SimulatorManager",
                .product(name: "ClassDump", package: "ClassDump"),
                .product(name: "ClassDumpDyld", package: "ClassDumpDyld"),
                .product(name: "ClassDumpRuntime", package: "ClassDumpRuntime"),
                .product(name: "ExceptionCatcher", package: "ExceptionCatcher"),
                .product(name: "FrameworkToolbox", package: "FrameworkToolbox"),
                .product(name: "FoundationToolbox", package: "FrameworkToolbox"),
                .product(name: "Apps", package: "Apps"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport"),
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
                .product(name: "SFSymbol", package: "SFSymbol"),
                .product(name: "AdvancedCollectionTableView", package: "AdvancedCollectionTableView"),
                .product(name: "IDEIcons", package: "ide-icons"),
                .product(name: "MenuBuilder", package: "MenuBuilder"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .target(name: "UtilitiesCore"),
        .target(
            name: "UtilitiesUI",
            dependencies: [
                "UtilitiesCore",
                .product(name: "FrameworkToolbox", package: "FrameworkToolbox"),
                .product(name: "FoundationToolbox", package: "FrameworkToolbox"),
                .product(name: "UIFoundation", package: "UIFoundation"),
                .product(name: "UIFoundationToolbox", package: "UIFoundation"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "ApplicationLaunchers",
            dependencies: [
                .product(name: "SwiftCommand", package: "SwiftCommand"),
            ]
        ),
        .target(
            name: "SimulatorManager",
            dependencies: [
                .product(name: "FrameworkToolbox", package: "FrameworkToolbox"),
                .product(name: "FoundationToolbox", package: "FrameworkToolbox"),
            ]
        ),
        .testTarget(
            name: "SimulatorManagerTests",
            dependencies: [
                "SimulatorManager",
            ]
        ),
    ]
)

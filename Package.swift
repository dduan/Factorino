// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Rename",
    products: [
        .executable(
            name: "renamer-cli",
            targets: ["RenamerCLI"]
        ),
        .library(
            name: "Renamer",
            targets: ["Renamer"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/indexstore-db.git", .branch("swift-5.1-branch")),
        .package(url: "https://github.com/apple/swift-argument-parser", .exact("0.0.2")),
        .package(url: "https://github.com/dduan/Pathos", .exact("0.2.2")),
    ],
    targets: [
        .target(
            name: "RenamerCLI",
            dependencies: [
                "ArgumentParser",
                "Renamer",
            ]
        ),
        .target(
            name: "Renamer",
            dependencies: [
                "IndexStoreDB",
                "Pathos",
            ]
        ),
        .testTarget(
            name: "RenamerTests",
            dependencies: [
                "Renamer",
            ]
        ),
    ]
)

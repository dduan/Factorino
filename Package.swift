// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Factorino",
    products: [
        .executable(
            name: "factorino-cli",
            targets: ["FactorinoCLI"]
        ),
        .library(
            name: "Factorino",
            targets: ["Factorino"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/indexstore-db.git", .branch("swift-5.1-branch")),
        .package(url: "https://github.com/apple/swift-argument-parser", .exact("0.0.2")),
        .package(url: "https://github.com/dduan/Pathos", .exact("0.2.2")),
    ],
    targets: [
        .target(
            name: "FactorinoCLI",
            dependencies: [
                "ArgumentParser",
                "Factorino",
            ]
        ),
        .target(
            name: "Factorino",
            dependencies: [
                "IndexStoreDB",
                "Pathos",
            ]
        ),
        .testTarget(
            name: "FactorinoTests",
            dependencies: [
                "Factorino",
            ]
        ),
    ]
)

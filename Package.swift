// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BrewExtension",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "BrewExtension",
            targets: ["BrewExtension"]),
    	.executable(
    	    name: "brew-extension",
    	    targets: ["brew-extension"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ArgParse",
            dependencies: []),
        .target(
            name: "BrewExtension",
            dependencies: ["Brew"]),
        .target(
            name: "Brew",
            dependencies: []),
    	.target(
    	    name: "brew-extension",
    	    dependencies: ["BrewExtension", "ArgParse"]),

        .testTarget(
            name: "BrewExtensionTests",
            dependencies: ["BrewExtension"]),
        .testTarget(
            name: "BrewTests",
            dependencies: ["Brew"]),
    ]
)

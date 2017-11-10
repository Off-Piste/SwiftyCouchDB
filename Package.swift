// swift-tools-version:4.0

import PackageDescription

typealias PDependency = Package.Dependency
typealias TDependency = Target.Dependency

extension Package {
    convenience init(
        name: String,
        dependencies: [Package.Dependency],
        targets: [Target])
    {
        self.init(
            name: name,
            products: [
                .library(
                    name: name,
                    targets: [
                        name
                    ]
                )
            ],
            dependencies: dependencies,
            targets: targets
        )
    }
}

// Will stick with Alamofire as it is the best for Networking tools
// easier than making my own to do the same purpose
let dependencies: [PDependency] = [
    .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .upToNextMinor(from: "1.7.0")),
    .package(url: "https://github.com/Alamofire/Alamofire.git", .exact("4.5.1")),
    .package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", .upToNextMinor(from: "17.0.0")),
    .package(url: "https://github.com/harrytwright/CodableCollection.git", .branch("master"))
]

let targetDependencies: [TDependency] = [
    .byNameItem(name: "HeliumLogger"),
    .byNameItem(name: "Alamofire"),
    .byNameItem(name: "SwiftyJSON"),
    .byNameItem(name: "CodableCollection")
]

let package = Package(
    name: "SwiftyCouchDB",
    dependencies: dependencies,
    targets: [
        .target(
            name: "SwiftyCouchDB",
            dependencies: targetDependencies,
            path: "./Sources"),
        .testTarget(
            name: "SwiftyCouchDBTests",
            dependencies: ["SwiftyCouchDB"],
            path: "./Tests")
    ]
)

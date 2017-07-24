// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "SwiftyCouchCB",
    dependencies: [
        .Package(
            url: "https://github.com/IBM-Swift/Kitura-CouchDB.git",
            majorVersion: 1
        )
    ]
)
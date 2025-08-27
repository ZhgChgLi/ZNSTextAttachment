// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZNSTextAttachment",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "ZNSTextAttachment",
            targets: ["ZNSTextAttachment"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ZNSTextAttachment",
            dependencies: [],
            path: "Sources",
            publicHeadersPath: nil
        ),
    ]
)

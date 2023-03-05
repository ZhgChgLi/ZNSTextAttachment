// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZNSTextAttachment",
    platforms: [.iOS(.v12), .macOS(.v10_14)],
    products: [
        .library(name: "ZNSTextAttachment", targets: ["ZNSTextAttachment"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "ZNSTextAttachment",
                path: "Sources"),
    ]
)

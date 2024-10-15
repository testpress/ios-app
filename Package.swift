// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "CourseKit",
  platforms: [
    .iOS(.v13),
  ],
  products: [
    .library(
      name: "CourseKit",
      targets: ["CourseKit"])
  ],
  dependencies: [
    .package(url: "https://github.com/realm/realm-swift/", .upToNextMajor(from: "10.49.3")),
    .package(url: "https://github.com/Hearst-DD/ObjectMapper", .upToNextMajor(from: "4.2.0")),
  ],


  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "CourseKit",
      dependencies: [
        .product(name: "RealmSwift", package: "realm-swift"),
        "ObjectMapper",
      ],
      path: "CourseKit/Source",
      resources: [
        .copy("Resources"),
        .process("PrivacyInfo.xcprivacy")
      ]
    )
  ],  
  swiftLanguageVersions: [
    .v5
  ]
)
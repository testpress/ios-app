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


  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "CourseKit",
      path: "CourseKit/Source",
      resources: [
        .process("Resources"),
        .process("PrivacyInfo.xcprivacy")
      ]
    )
  ],  
  swiftLanguageVersions: [
    .v5
  ]
)
// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "CourseKit",
  defaultLocalization: "en",
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
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1")),
    .package(url: "https://github.com/getsentry/sentry-cocoa.git", .upToNextMajor(from: "8.36.0")),
    .package(url: "https://github.com/M3U8Kit/M3U8Parser", .upToNextMajor(from: "1.1.0")),
    .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "7.11.0")),
    .package(url: "https://github.com/testpress/MarqueeLabel", .upToNextMajor(from: "4.3.2")),
    .package(url: "https://github.com/testpress/SlideMenuControllerSwift", .upToNextMajor(from: "5.0.1")),
    .package(url: "https://github.com/testpress/DropDown-Swift", .upToNextMajor(from: "2.3.14")),
    .package(url: "https://github.com/scinfu/SwiftSoup", .upToNextMajor(from: "2.5.3")),
    .package(url: "https://github.com/ChartsOrg/Charts", .upToNextMajor(from: "5.1.0")),
    .package(url: "https://github.com/zekunyan/TTGSnackbar", .upToNextMajor(from: "1.11.1")),
    .package(url: "https://github.com/instagram/IGListKit", branch: "main"),
    .package(url: "https://github.com/xmartlabs/XLPagerTabStrip", .upToNextMajor(from: "9.1.0")),
    .package(url: "https://github.com/airbnb/lottie-ios", .upToNextMajor(from: "4.4.3")),
    .package(url: "https://github.com/LaurentiuUngur/LUExpandableTableView", .upToNextMajor(from: "6.0.0")),
  ],


  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "CourseKit",
      dependencies: [
        .product(name: "RealmSwift", package: "realm-swift"),
        "ObjectMapper",
        "Alamofire",
        "M3U8Parser",
        .product(name: "Sentry", package: "sentry-cocoa"),
        "Kingfisher",
        "MarqueeLabel",
        .product(name:"SlideMenuController", package: "SlideMenuControllerSwift"), 
        .product(name: "DropDown", package: "DropDown-Swift"),
        "SwiftSoup",
        .product(name: "DGCharts", package: "Charts"),
        "LUExpandableTableView",
        "TTGSnackbar",
        "IGListKit",
        "XLPagerTabStrip",
        .product(name: "Lottie", package: "lottie-ios"),
      ],
      path: "CourseKit/Source",
      resources: [
        .copy("Resources/static"),
        .process("Resources/Assets.xcassets"),
        .process("PrivacyInfo.xcprivacy")
      ]
    )
  ],  
  swiftLanguageVersions: [
    .v5
  ]
)
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
    .package(url: "https://github.com/realm/realm-swift.git", .upToNextMajor(from: "10.54.2")),
    .package(url: "https://github.com/Hearst-DD/ObjectMapper.git", .upToNextMajor(from: "4.2.0")),
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1")),
    .package(url: "https://github.com/getsentry/sentry-cocoa.git", .upToNextMajor(from: "8.36.0")),
    .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.11.0")),
    .package(url: "https://github.com/testpress/MarqueeLabel.git", .upToNextMajor(from: "4.3.2")),
    .package(url: "https://github.com/testpress/SlideMenuControllerSwift.git", .upToNextMajor(from: "5.0.1")),
    .package(url: "https://github.com/testpress/DropDown-Swift.git", .upToNextMajor(from: "2.3.14")),
    .package(url: "https://github.com/scinfu/SwiftSoup.git", .upToNextMajor(from: "2.5.3")),
    .package(url: "https://github.com/ChartsOrg/Charts.git", .upToNextMajor(from: "5.1.0")),
    .package(url: "https://github.com/zekunyan/TTGSnackbar.git", .upToNextMajor(from: "1.11.1")),
    .package(url: "https://github.com/instagram/IGListKit.git", branch: "main"),
    .package(url: "https://github.com/xmartlabs/XLPagerTabStrip.git", .upToNextMajor(from: "9.1.0")),
    .package(url: "https://github.com/airbnb/lottie-ios.git", .upToNextMajor(from: "4.4.3")),
    .package(url: "https://github.com/LaurentiuUngur/LUExpandableTableView.git", .upToNextMajor(from: "6.0.0")),
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
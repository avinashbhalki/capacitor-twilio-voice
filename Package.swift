// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AvinashbhalkiCapacitorTwilioVoice",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "AvinashbhalkiCapacitorTwilioVoice",
            targets: ["AvinashbhalkiCapacitorTwilioVoice"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main"),
        .package(url: "https://github.com/twilio/twilio-voice-ios", from: "6.9.0")
    ],
    targets: [
        .target(
            name: "AvinashbhalkiCapacitorTwilioVoice",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "TwilioVoice", package: "twilio-voice-ios")
            ],
            path: "ios/Plugin")
    ]
)
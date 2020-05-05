// swift-tools-version:5.0

import PackageDescription

let package = Package(
	name: "Pact_macOS_Example",
	platforms: [
		.macOS(.v10_12),
		.iOS(.v12),
		.tvOS(.v12)
	],
	products: [
		.library(
			name: "Pact_macOS_Example",
			targets: ["Pact_macOS_Example"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/surpher/PactSwift.git", .branch("master"))
	],
	targets: [
		.target(
			name: "Pact_macOS_Example",
			dependencies: [],
			path: "./Pact-macOS-Example"
		),
		.testTarget(
			name: "Pact_macOS_ExampleTests",
			dependencies: [
				"Pact_macOS_Example",
				"PactSwift",
			],
			path: "./Pact-macOS-ExampleTests"
		),
	],
	swiftLanguageVersions: [.v5]
)

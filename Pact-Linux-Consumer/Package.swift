// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "SwiftHTTP",

	dependencies: [
		// Dependencies declare other packages that this package depends on.
		.package(name: "PactSwift", url: "https://github.com/surpher/PactSwift.git", .upToNextMajor(from: "1.0.0")),
	],

	targets: [
	// Targets are the basic building blocks of a package. A target can define a module or a test suite.
	// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "SwiftHTTP",
			dependencies: ["SWAPIClient"]
		),

		.target(
			name: "SWAPIClient",
			dependencies: [],
			path: "Sources/SWAPIClient"
		),

		.testTarget(
			name: "SwiftHTTPTests",
			dependencies: [
				"SwiftHTTP",
				"PactSwift",
			]
		),
	]

)

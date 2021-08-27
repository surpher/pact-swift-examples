// swift-tools-version:5.2
import PackageDescription

let package = Package(
	name: "AnimalService",
	platforms: [
		.macOS(.v10_15)
	],

	dependencies: [
		// 💧 A server-side Swift web framework.
		.package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
		.package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
		.package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),

		// 🤝 PactSwift - Consumer driven contract testing
		// .package(name: "PactSwift", url: "https://github.com/surpher/PactSwift.git", .upToNextMajor(from: "0.9.0")),
		.package(url: "https://github.com/surpher/PactSwift.git", .branch("provider/verification")),
	],

	targets: [
		.target(
			name: "App",
			dependencies: [
				.product(name: "Fluent", package: "fluent"),
				.product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
				.product(name: "Vapor", package: "vapor"),
			],
			swiftSettings: [
				// Enable better optimizations when building in Release configuration. Despite the use of
				// the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
				// builds. See <https://github.com/swift-server/guides/blob/main/docs/building.md#building-for-production> for details.
				.unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
			]
		),
		.target(name: "Run", dependencies: [.target(name: "App")]),
		.testTarget(name: "AppTests", dependencies: [
			.target(name: "App"),
			.product(name: "XCTVapor", package: "vapor"),
			.product(name: "PactSwift", package: "PactSwift"),
		])
	]
)

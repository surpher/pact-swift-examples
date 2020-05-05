# Using SPM

Add `PactSwift` as a test dependecy to `Package.swift`:

	.package(url: "https://github.com/surpher/PactSwift.git", .branch("master")) // <- # Define dependency
	...
	targets: [
		.testTarget(
			name: "Pact_macOS_ExampleTests",
			dependencies: [
				"Pact_macOS_Example",
				"PactSwift", // <- # Add it to Test target
			],
			path: "./Pact-macOS-ExampleTests"
		)
	]

Download `libpact_mock_server.a` framework and add it somewhere in your Test folder (eg: `/ProjectNameTests/lib`)

Write your tests in `ProjectNameTests/test_suite.swift`

In your terminal run:

	swift test -Xlinker -LProjectNameTests/lib
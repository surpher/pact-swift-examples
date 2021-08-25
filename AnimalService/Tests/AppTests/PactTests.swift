@testable import App
import Foundation
import XCTVapor
import PactSwift
import XCTest

final class PactTests: XCTestCase {

	func testProvider_using_PactSwift() throws {
		let app = Application(.testing)
		try configure(app)
		try app.start()

		//
		// Prepare the state for the specific provider state in the Pact contract where it interaction expects to hit `/api/animals/0221825F-CD8F-4570-A034-BF74915C40A5`
		// and provider responds with data...
		//
		// Alternatively a Controller for state change handler can be created and exposed only for test runs
		// see: https://stackoverflow.com/a/46418593/789720 for more
		//
		let species = try Species.create(name: "Alligator", on: app.db)
		try Animal.create(id: UUID(uuidString: "0221825F-CD8F-4570-A034-BF74915C40A5"), name: "Mary", speciesID: species.id!, on: app.db)

		// WHEN verifying the provider
		let verifier = ProviderVerifier()

		guard let token = ProcessInfo.processInfo.environment["PACTFLOW_TOKEN"] else {
			XCTFail("Missing token! Make sure you've set one in an env var PACTFLOW_TOKEN.")
			return
		}

		var providerTags = [String]()
		let providerVersionHash = ProcessInfo.processInfo.environment["GITHUB_SHA"]
		let providerVersionGithubRef = ProcessInfo.processInfo.environment["GITHUB_REF"]

		if let _ = ProcessInfo.processInfo.environment["CI"] {
			providerTags.append("SIT")
			providerTags.append("v0.0.5")
			if let githubRef = providerVersionGithubRef { providerTags.append(githubRef) }
		} else {
			providerTags.append("dev")
		}

		let pactBroker = PactBroker(
			url: URL(string: "https://surpher.pactflow.io")!,
			auth: .token(PactBroker.APIToken(token: token)),
			providerName: "AnimalService",
			consumerTags: [VersionSelector(tag: "prod")],
			publishResults: PactBroker.VerificationResults(providerVersion: "v0.0.4-\(providerVersionHash ?? "")", providerTags: providerTags)
		)

		let options = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .broker(pactBroker),
			logLevel: .none
		)

		let result = verifier.verify(options: options) {
			// Shut down the server when verification is done
			app.shutdown()
		}

		// THEN we expect a successful result
		guard case .success = result else {
			XCTFail("Expected a successful verification result")
			return
		}
	}

}

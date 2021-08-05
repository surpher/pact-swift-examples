import PactSwift
@testable import SWAPIClient
import XCTest

class MockServiceWrapper {
	static let shared = MockServiceWrapper()
	var mockService: MockService

	private init() {
		mockService = MockService(consumer: "macOS_app", provider: "test_provider")
	}
}

final class SwiftHTTPTests: XCTestCase {

	private let mockService = MockServiceWrapper.shared.mockService
	private var apiClient: SWAPIClient!

	override func setUpWithError() throws {
		try super.setUpWithError()

		apiClient = SWAPIClient(baseURL: mockService.baseUrl)
	}

	func testMakesRequest() {

		mockService
		.uponReceiving("A request for a list of users")
		.given("users exist")
		.withRequest(
			method: .GET,
			path: "/people/1"
		)
		.willRespondWith(
			status: 200
		)

		mockService.run { [unowned self] completed in
			apiClient.fetch(endpoint: SWAPIClient.Endpoint.people, id: 1, completion: { (result: SWPerson?, error) in
				// In this particular test we defined the response will be a status: 200. In order to get a result: SWPerson!, we need
				// to write `.willRespondWith(status: 200, body: [ ...DSL defining a response body for SWPerson... ])`
				// for now, as long as the request is made, mockServer gets the request to /people/1/, we're golden.
				completed()
			})

		}

	}

	func testMakesPOSTRequest() {
		mockService
			.uponReceiving("Request to POST foo:bar")
			.given("foo:bar does not exist")
			.withRequest(
				method: .POST,
				path: "/starships",
				body: [
					"foo": Matcher.SomethingLike("bar"),
					"baz": Matcher.IntegerLike(1)
				]
			)
			.willRespondWith(
				status: 201
			)

		mockService.run { [unowned self] completed in
			apiClient
				.submit(endpoint: SWAPIClient.Endpoint.starships, method: .POST, body: Data(#"{"foo": "bar","baz":1}"#.utf8)) { (result: SWStarship?, error) in
					completed()
				}
		}
	}

}

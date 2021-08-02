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

	let mockService = MockServiceWrapper.shared.mockService

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
			let apiClient = SWAPIClient(baseURL: mockService.baseUrl)
			apiClient.fetch(endpoint: SWAPIClient.Endpoint.people, id: 1, completion: { (result: SWPerson?, error) in
				// In this particular test we defined the response will be a status: 200. In order to get a result: SWPerson!, we need
				// to write `.willRespondWith(status: 200, body: [ ...DSL defining a response body for SWPerson... ])`
				// for now, as long as the request is made, mockServer gets the request to /people/1/, we're golden.
				completed()
			})

		}

	}

}

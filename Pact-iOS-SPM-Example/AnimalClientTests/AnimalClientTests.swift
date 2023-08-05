@testable import AnimalClient
import PactSwift
import XCTest

class MockProvider {
	static let shared = MockProvider()
	var mockService: MockService

	private init() {
		mockService = MockService(consumer: "AnimalClient", provider: "AnimalService")
	}
}

class AnimalClientTests: XCTestCase {

	var mockService: MockService!

    override func setUpWithError() throws {
        try super.setUpWithError()

        mockService = MockProvider.shared.mockService

    }

	func testCreatingASpecies() {
		mockService
			.uponReceiving("a request to create a species")
			.withRequest(
				method: .POST,
				path: "/api/species",
                headers: [
                    "Content-Type": "application/json"
                ],
                body: [
					"application": Matcher.SomethingLike("XxzUY5DqEpr7YRsdXiiZ"),
                    "token": Matcher.SomethingLike("AxzPOIQqEpr7YRsdXiiB"),
                    "applicationVersion": Matcher.SomethingLike("0.0.0"),
                    "deviceName": Matcher.SomethingLike("deviceName"),
                    "platform": Matcher.SomethingLike("platform"),
                    "platformVersion": Matcher.SomethingLike("platformVersion"),
                    "language": Matcher.SomethingLike("language")
                ]
			)
			.willRespondWith(
				status: 201,
				body: [
					"id": Matcher.SomethingLike("BDA52033-F0F1-4EC3-8CA4-E04D71572913"),
					"name": Matcher.SomethingLike("Alligator")
				]
			)

        let requestBody = "{\"application\":\"a\",\"token\":\"b\",\"applicationVersion\":\"1.0.0\",\"deviceName\":\"c\",\"platform\":\"d\",\"platformVersion\":\"e\",\"language\":\"f\"}".data(using: .utf8)!

		mockService.run { baseURL, done in
			AnimalClient(baseURL: baseURL)
				.request(method: .POST, endpoint: .species, body: requestBody) { (species: Species?, error) in
					do {
						let species = try XCTUnwrap(species)
						// Assert things here
						debugPrint("🐊: \(species)")
					} catch {
						XCTFail("Expected a Species object returned")
					}
					done()
				}
			}
	}

	func testNonExistingAnimal() {
		mockService
			.uponReceiving("a request for a non-existing animal")
			.withRequest(method: .GET, path: "/api/animals/bogus-identifier")
			.willRespondWith(status: 404)

		mockService.run { baseURL, done in
			AnimalClient(baseURL: baseURL)
				.request(method: .GET, endpoint: .animals, path: "bogus-identifier", query: nil, body: nil) { (animal: Animal?, error) in
					XCTAssertNotNil(error)
					if let animalServiceError = error as? AnimalServiceError, case .statusCode(let statusCode) = animalServiceError {
						debugPrint("☣️ non existing animal with status code: \(statusCode)")
						XCTAssertEqual(statusCode, 404)
					} else {
						XCTFail("Expected AnimalServiceError!")
					}
					done()
				}
		}
	}

}

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

	func testGetsAnimals() {
		// Set the API behaviour expectations
		mockService
			.uponReceiving("a request for a list of animals")
			.given("animals exist")
			.withRequest(
				method: .GET,
				path: "/api/animals"
			)
			.willRespondWith(
				status: 200,
				body: Matcher.EachLike(
					[
						"name": Matcher.SomethingLike("Mary"),
						"age": Matcher.IntegerLike(23),
						"next_vacc_date": ExampleGenerator.DateTimeExpression(expression: "today + 1 month @ 5pm", format: "yyyy-MM-dd hh:mm"),
					],
					min: 0
				)
			)

		// Test our own network client
		mockService.run { baseURL, done in
			// Run the GET /api/animals request
			AnimalClient(baseURL: baseURL)
				.request(method: .GET, endpoint: .animals) { (animals: [Animal]?, error) in
					guard error == nil else {
						XCTFail("Failed with \(String(describing: error))")
						done()
						return
					}

					do {
						// When our client receives the payload, it can serialize it
						let animals = try XCTUnwrap(animals)

						// And that one of the Animals' name is "Mary"
						let alligatorMary = animals.firstIndex { $0.name == "Mary" }
						XCTAssertNotNil(alligatorMary)
					} catch {
						XCTFail("Expected an array of Animals")
					}

					done()
				}
			}
	}

	func testGetAnimalByID() {
		mockService
			.uponReceiving("a request for Alligator Mary")
			.given(ProviderState(description: "Mary exists", params: ["name": "Mary", "id": "0221825F-CD8F-4570-A034-BF74915C40A5"]))
			.withRequest(
				method: .GET,
				path: Matcher.RegexLike(
					"/api/animals/0221825F-CD8F-4570-A034-BF74915C40A5",
					term: "^/api/animals/[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}"
				)
			)
			.willRespondWith(
				status: 200,
				body: [
					"name": "Mary",
					"age": Matcher.IntegerLike(23)
				]
			)

		mockService.run { baseURL, done in
			AnimalClient(baseURL: baseURL)
				.request(method: .GET, endpoint: .animals, path: "0221825F-CD8F-4570-A034-BF74915C40A5") { (animal: Animal?, error) in
					do {
						let animal = try XCTUnwrap(animal)
						print(animal)
					} catch {
						XCTFail("Expected an Animal")
					}
					done()
				}
			}
	}

	func testSearchAnimalWithID() {
		mockService
			.uponReceiving("a request searching for Alligator Mary")
			.given("Mary exists")
			.withRequest(
				method: .GET,
				path: "/api/animals/search/mary"
			)
			.willRespondWith(
				status: 200,
				body: [
					"name": "Mary",
					"age": Matcher.IntegerLike(23)
				]
			)

		mockService.run(timeout: 10) { baseURL, done in
			AnimalClient(baseURL: baseURL)
				.request(method: .GET, endpoint: .animals, path: "search/mary") { (animal: Animal?, error) in
					do {
						let animal = try XCTUnwrap(animal)
						print(animal)
					} catch {
						XCTFail("Expected an Animal")
					}
					done()
				}
			}
	}

	func testGetSpecies() {
		mockService
			.uponReceiving("a request for a list of species")
			.given("species exist")
			.withRequest(
				method: .GET,
				path: "/api/species"
			)
			.willRespondWith(
				status: 200,
				body: Matcher.EachLike(
					[
						"id": Matcher.SomethingLike("BDA52033-F0F1-4EC3-8CA4-E04D71572913"),
						"name": ExampleGenerator.RandomString()
					]
				)
			)

		mockService.run { baseURL, done in
			AnimalClient(baseURL: baseURL)
				.request(method: .GET, endpoint: .species) { (species: [Species]?, error) in
					do {
						let species = try XCTUnwrap(species)

						print(species)

						XCTAssertTrue(species.count > 0)
					} catch {
						XCTFail("Expected an array of Species")
					}

					done()
				}
			}
	}

	func testGetSpeciesWithAnimals() {
		mockService
			.uponReceiving("a request for a list of species and its animals")
			.given("species exist")
			.withRequest(
				method: .GET,
				path: "/api/species",
				query: [
					"showChildren" : ["true"]
				]
			)
			.willRespondWith(
				status: 200,
				body: Matcher.EachLike(
					[
						"id": Matcher.SomethingLike("BDA52033-F0F1-4EC3-8CA4-E04D71572913"),
						"name": ExampleGenerator.RandomString(),
						"animals": Matcher.EachLike(
							[
								"id": Matcher.SomethingLike("BDA52033-F0F1-4EC3-8CA4-E04D71572913"),
								"name": Matcher.SomethingLike("Mary"),
								"age": Matcher.IntegerLike(23)
							]
							, min: 0
						)
					]
				)
			)

		mockService.run { baseURL, done in
			AnimalClient(baseURL: baseURL)
				.request(method: .GET, endpoint: .species, query: "?showChildren=true") { (species: [Species]?, error) in
					do {
						let species = try XCTUnwrap(species)

						print(species)

						XCTAssertTrue(species.count > 0)
					} catch {
						XCTFail("Expected an array of Species")
					}

					done()
				}
			}
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
					"name": Matcher.SomethingLike("Alligator")
				]
			)
			.willRespondWith(
				status: 201,
				body: [
					"id": Matcher.SomethingLike("BDA52033-F0F1-4EC3-8CA4-E04D71572913"),
					"name": Matcher.SomethingLike("Alligator")
				]
			)

		mockService.run { baseURL, done in
			AnimalClient(baseURL: baseURL)
				.request(method: .POST, endpoint: .species, body: "{\"name\":\"Alligator\"}".data(using: .utf8)) { (species: Species?, error) in
					do {
						let species = try XCTUnwrap(species)
						// Assert things here
						debugPrint(species)
					} catch {
						XCTFail("Expected a Species object")
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
						XCTAssertEqual(statusCode, 404)
					} else {
						XCTFail("Expected AnimalServiceError!")
					}
					done()
				}
		}
	}

}

//
//  Pact_iOS_Spec2_ExampleTests.swift
//  Pact-iOS-Spec2-ExampleTests
//
//  Created by Marko Justinek on 12/5/21.
//

import XCTest
import PactSwift_spec2

class MockServiceWrapper {
	static let shared = MockServiceWrapper()
	var mockService: MockService

	private init() {
		mockService = MockService(consumer: "ThisApp", provider: "SWAPI-api-provider")
	}
}

@testable import Pact_iOS_Spec2_Example

class Pact_iOS_Spec2_ExampleTests: XCTestCase {

	// MARK: - Properties

	var mockService: MockService!
	var apiClient: SWAPIClient!

	// MARK: - Lifecycle

	override func setUpWithError() throws {
		mockService = MockServiceWrapper.shared.mockService
		apiClient = SWAPIClient(baseURL: mockService.baseUrl)
	}

	override func tearDownWithError() throws {

	}

	// MARK: - Tests

	func testFetchingASpecificStarWarsCharacter() throws {
		// Setup API interaction expectations
		mockService
			.uponReceiving("a request for a character")
			.withRequest(
				method: .GET,
				path: "/people/1",
				headers: [
					"Authorization": Matcher.SomethingLike("Bearer"),
					"Accept": "application/json"
				]
			)
			.given("a character exists")
			.willRespondWith(
				status: 200,
				body: [
					"name": Matcher.SomethingLike("Luke Skywalker"),
					"eye_color": "blue",
					"birth_year": "19BBY",
					"films": Matcher.EachLike("https://swapi.co/api/films/2/"),
					"species": Matcher.EachLike("https://swapi.co/api/species/1/", min: 1),
					"edited": Matcher.RegexLike("2014-12-20T21:17:56.891000Z", term: "\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}.\\d{,6}Z")
				]
			)

		// Run Pact test
		mockService.run(waitFor: 5) { [apiClient] testCompleted in
			apiClient!.fetch(endpoint: .people, id: 1) { (result: SWPerson?, error) in
				// Assert
				do {
					let person = try XCTUnwrap(result)

					XCTAssertEqual(person.name, "Luke Skywalker")
					XCTAssertEqual(person.eyeColor, "blue")
					XCTAssertEqual(person.edited, "2014-12-20T21:17:56.891000Z")
					XCTAssertTrue(person.films.contains("https://swapi.co/api/films/2/"))
					XCTAssertTrue(person.species.count == 1)
				} catch {
					XCTFail("Expected a SWPerson object")
				}

				// Notify our mockService that test has completed
				testCompleted()
			}
		}

	}

	func testFetchingAStarWarsCharacter_ReturnsError() {
		// Setup API interaction expectations
		mockService
			.uponReceiving("a request for a character")
			.withRequest(
				method: .GET,
				path: "/people/999999",
				headers: [
					"Authorization": Matcher.SomethingLike("Bearer"),
					"Accept": "application/json"
				]
			)
			.given("a character does not exist")
			.willRespondWith(
				status: 404,
				body: [ "404 Error" ]
			)

		// Run Pact test
		mockService.run { [unowned self] testCompleted in
			apiClient.fetch(endpoint: .people, id: 999999) { (result: SWPerson?, error) in
				do {
					let error = try XCTUnwrap(error as? SWAPIError)
					guard case .statusCode(let code) = error else {
						XCTFail("Expected a status code error")
						return
					}
					XCTAssertEqual(code, 404)
				} catch {
					XCTFail("Expected a SWAPIError")
				}

				// Notify our mockService that test has completed
				testCompleted()
			}
		}
	}

	func testFetchingStarWarsPlanet() {
		// Setup API interaction expectations
		mockService
			.uponReceiving("a request for a planet")
			.withRequest(method: .GET, path: "/planets/12")
			.given("a planet exists")
			.willRespondWith(
				status: 200,
				body: [
					"name": Matcher.SomethingLike("Utapau"),
					"rotation_period": "27",
					"orbital_period": "351",
					"diameter": "12900",
					"climate": "temperate, arid, windy",
					"gravity": "1 standard",
					"terrain": "scrublands, savanna, canyons, sinkholes",
					"surface_water": "0.9",
					"residents": Matcher.EachLike(
						Matcher.RegexLike(
							"http://swapi.dev/api/people/83/",
							term: "^(http[s]?:\\/\\/(www\\.)?|ftp:\\/\\/(www\\.)?|www\\.){1}([0-9A-Za-z-\\.@:%_\\+~#=]+)+((\\.[a-zA-Z]{2,3})+)(/(.)*)?(\\?(.)*)?"
						),
						min: 3
					)
				]
			)

		// Run Pact test
		mockService.run(waitFor: 1) { [apiClient] testComplete in
			apiClient!.fetch(endpoint: .planets, id: 12) { (planet: SWPlanet?, error) in
				do {
					let planet = try XCTUnwrap(planet)

					XCTAssertEqual(planet.name, "Utapau")
					XCTAssertEqual(planet.orbitalPeriod, "351")
					XCTAssertEqual(planet.residents.count, 3)
				} catch {
					XCTFail("Expected a SWPlanet object")
				}

				// Notify our mockService that test has completed
				testComplete()
			}
		}
	}

	func testFetchingAListOfStarships() {
		// Setup API interaction expectations
		mockService
			.uponReceiving("a request for a list of starships")
			.withRequest(method: .GET, path: "/starships")
			.given("starships exist")
			.willRespondWith(
				status: 200,
				body: [
					"count": Matcher.SomethingLike(99),
					"results": Matcher.EachLike(
						[
							"name": Matcher.SomethingLike("CR90 corvette"),
							"model": Matcher.SomethingLike("CR90 corvette"),
							"manufacturer": "Corellian Engineering Corporation",
							"cost_in_credits": "3500000",
							"length": "150",
							"max_atmosphering_speed": Matcher.SomethingLike("950"),
							"crew": "30-165",
							"passengers": "600",
							"cargo_capacity": "3000000",
							"films": Matcher.EachLike(
								Matcher.SomethingLike("http://swapi.dev/api/films/1/")
							)
						],
						min: 2
					)
				]
			)

		// Run Pact test
		mockService.run { [unowned self] testComlete in
			apiClient.fetch(
				endpoint: .starships,
				completion: { (starships: SWStarshipsList?, error) in
					do {
						let starships = try XCTUnwrap(starships)

						XCTAssertEqual(starships.count, 99)
						XCTAssertEqual(starships.results.count, 2)

						let starship = try XCTUnwrap(starships.results.first)
						XCTAssertEqual(starship.films.count, 1)
						XCTAssertEqual(starship.maxAtmospheringSpeed, "950")
					} catch {
						XCTFail("Expected a SWStarshipsList object")
					}

					// Notify our mockService that test has completed
					testComlete()
				}
			)
		}
	}

}


//
//  XCTestPassingExampleTests.swift
//  XCTestExampleTests
//
//  Created by Marko Justinek on 23/4/20.
//  Copyright © 2020 Pact Foundation. All rights reserved.
//

import XCTest
import PactSwift

@testable import Pact_iOS_Example

class PassingTestsExample: XCTestCase {

	var mockService = MockService(consumer: "iOS_app", provider: "test_provider")

	// MARK: - Tests

	func testGetsUsers() {
		// Expectations
		mockService
			.uponReceiving("A request for a list of users")
			.given("users exist and more")
			.withRequest(
				method: .GET,
				path: "/api/users"
			)
			.willRespondWith(
				status: 200,
				body: userDataResponse
			)

		let apiClient = RestManager()

		// Testing the expectations by running our makeRequest() method,
		// pointing it to the mockService we programmed it just above

		// This following block tests our RestManager implementation...
		mockService.run { [unowned self] completed in
			guard let url = URL(string: "\(self.mockService.baseUrl)/api/users") else {
				XCTFail("Failed to prepare url!")
				return
			}

			// This is using our API Client implementation in the main target.
			apiClient.makeRequest(toURL: url, withHttpMethod: .get) { results in
				if let data = results.data {
					let decoder = JSONDecoder()
					decoder.keyDecodingStrategy = .convertFromSnakeCase
					guard let userData = try? decoder.decode(UserData.self, from: data) else {
						// There's something with the structure of data either on our end, or how we defined the body we are expecting...
						// Either way, they don't match meaning there's something wrong with our decoder implementation (or model) or body defined in .willRespondWith(...)
						XCTFail("Failed to decode UserData")
						completed() // Notify MockService we're done with our test
						return
					}

					// test the response from server is what we expected and it decodes into userData
					XCTAssertEqual(userData.page, 1)
					XCTAssertEqual(userData.data?.first?.firstName, "John")
					XCTAssertEqual(userData.data?.first?.lastName, "Tester")
				}
				completed() // Notify MockService we're done with our test
			}
		}
	}

	func testGetsUsers_over_SSL() {
		// Set MockService to start up using TLS (using a self-signed certificate)
		let secureMockService = MockService(consumer: "secure-consumer", provider: "secure-provider", scheme: .secure)
		_ = secureMockService
			.uponReceiving("A request for a list of users over SSL")
			.given("users exist and more")
			.withRequest(
				method: .GET,
				path: "/api/users"
			)
			.willRespondWith(
				status: 200,
				body: userDataResponse
			)

		let apiClient = RestManager()

		// Testing the expectations by running our makeRequest() method,
		// pointing it to the mockService we programmed it just above

		// This following block tests our RestManager implementation...
		secureMockService.run(waitFor: 1) { completed in
			guard let url = URL(string: "\(secureMockService.baseUrl)/api/users") else {
				XCTFail("Failed to prepare url!")
				return
			}

			// This is using our API Client implementation in the main target.
			apiClient.makeRequest(toURL: url, withHttpMethod: .get) { results in
				if let data = results.data {
					let decoder = JSONDecoder()
					decoder.keyDecodingStrategy = .convertFromSnakeCase
					guard let userData = try? decoder.decode(UserData.self, from: data) else {
						XCTFail("Failed to decode UserData")
						completed() // Notify MockService we're done with our test
						return
					}

					// test the response from server is what we expected and it decodes into userData
					XCTAssertEqual(userData.page, 1)
					XCTAssertEqual(userData.data?.first?.firstName, "John")
					XCTAssertEqual(userData.data?.first?.lastName, "Tester")
				}
				completed() // Notify MockService we're done with our test
			}
		}
	}

	func testGetsSingleUser() {
		// Expectations
		mockService
			.uponReceiving("A request for user")
			.given(ProviderState(description: "user exists", params: ["id": "1"]))
			.withRequest(
				method: .GET,
				path: "/api/users/1"
			)
			.willRespondWith(
				status: 200,
				body: singleUserResponse
			)

		let apiClient = RestManager()
		let userId = 1

		// Testing the expectations by running our makeRequest() method,
		// pointing it to the mockService we programmed it just above

		// This following block tests our RestManager implementation...
		mockService.run { [unowned self] completed in
			guard let url = URL(string: "\(self.mockService.baseUrl)/api/users/\(userId)") else {
				XCTFail("Failed to prepare url!")
				return
			}

			// This is using our API Client implementation in the main target.
			apiClient.makeRequest(toURL: url, withHttpMethod: .get) { results in
				if let data = results.data {
					let decoder = JSONDecoder()
					decoder.keyDecodingStrategy = .convertFromSnakeCase
					guard let userData = try? decoder.decode(SingleUserData.self, from: data) else {
						// There's something with the structure of data either on our end, or how we defined the body we are expecting...
						// Either way, they don't match meaning there's something wrong with our decoder implementation (or model) or body defined in .willRespondWith(...)
						XCTFail("Failed to decode UserData")
						completed() // Notify MockService we're done with our test
						return
					}

					// test the response from server is what we expected and it decodes into userData
					XCTAssertEqual(userData.data?.id, 1)
					XCTAssertEqual(userData.data?.firstName, "John")
					XCTAssertEqual(userData.data?.lastName, "Tester")
				}
				completed() // Notify MockService we're done with our test
			}
		}
	}

	func testGetsUsers_WithRequestQuery() {
		// Expectations
		mockService
			.uponReceiving("A request for list of users")
			.given(ProviderState(description: "users exists", params: ["page": "3"]))
			.withRequest(
				method: .GET,
				path: "/api/users",
				query: ["page": [Matcher.SomethingLike("4")]]
			)
			.willRespondWith(
				status: 200,
				headers: ["Content-Type": "application/json"],
				body: userDataResponse
			)

		let apiClient = RestManager()

		// This following block tests our RestManager implementation...
		mockService.run { [unowned self] completed in
			guard let url = URL(string: "\(self.mockService.baseUrl)/api/users?page=3") else {
				XCTFail("Failed to prepare url!")
				return
			}

			// This is using our API Client implementation in the main target.
			apiClient.makeRequest(toURL: url, withHttpMethod: .get) { results in
				if let data = results.data {
					let decoder = JSONDecoder()
					decoder.keyDecodingStrategy = .convertFromSnakeCase
					guard let userData = try? decoder.decode(UserData.self, from: data) else {
						// There's something with the structure of data either on our end, or how we defined the body we are expecting...
						// Either way, they don't match meaning there's something wrong with our decoder implementation (or model) or body defined in .willRespondWith(...)
						XCTFail("Failed to decode UserData")
						completed() // Notify MockService we're done with our test
						return
					}

					// test the response from server is what we expected and it decodes into userData
					XCTAssertEqual(userData.page, 1)
					XCTAssertEqual(userData.data?.first?.firstName, "John")
					XCTAssertEqual(userData.data?.first?.lastName, "Tester")
				}
				completed() // Notify MockService we're done with our test
			}
		}
	}

	func testCreateUser_WithBodyThatMatchesAType() {
		// Expectations
		mockService
			.uponReceiving("A request to create a user")
			.given(ProviderState(description: "user does not exist", params: ["name" : "Julia"]))
			.withRequest( // this is what we promise our apiClient will call
				method: .POST,
				path: "/api/users",
				body: [
					"name": Matcher.SomethingLike("Julia") // We only say we care about the key name ("name") and the type of value (a `String` should be expected)
				]
			)
			.willRespondWith(
				status: 201
			)

		let apiClient = RestManager()

		mockService.run(waitFor: 1) { completed in
			guard let url = URL(string: "\(self.mockService.baseUrl)/api/users") else {
				XCTFail("Failed to prepare url!")
				return
			}

			// This is using our API Client implementation in the main target.
			apiClient.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
			apiClient.httpBodyParameters.add(value: "Someones Name", forKey: "name") // We only promised we will send a `String`, so we're golden

			apiClient.makeRequest(toURL: url, withHttpMethod: .post) { results in
				// Do some assertions here that the 201 response is returned and handled by our apiClient?
				completed() // Notify MockService we're done with our test
			}
		}
	}

	func testGetsUsers_UsingExampleGenerators() {
		// Expectations
		mockService
			.uponReceiving("A request for list of users (using example generators)")
			.given(ProviderState(description: "users exists", params: ["page": "3"]))
			.withRequest(
				method: .GET,
				path: "/api/users",
				query: ["page": ["3"]]
			)
			.willRespondWith(
				status: 200,
				headers: ["Content-Type": "application/json"],
				body: [
					"page": ExampleGenerator.RandomInt(min: 0, max: 100),
					"per_page": Matcher.SomethingLike(25),
					"total": ExampleGenerator.RandomInt(min: 0, max: 500),
					"total_pages": ExampleGenerator.RandomInt(min: 1, max: 500),
					"data": [
						[
							"id": Matcher.SomethingLike(1),
							"uuid": ExampleGenerator.RandomUUID(),
							"first_name": Matcher.SomethingLike("John"),
							"last_name": Matcher.SomethingLike("Tester"),
							"joined": ExampleGenerator.RandomDate(format: "dd.MM.yyyy"),
							// and we don't care about the avatar 🤷‍♂️
						]
					]
				]
			)

		let apiClient = RestManager()

		// This following block tests our RestManager implementation...
		mockService.run { [unowned self] completed in
			guard let url = URL(string: "\(self.mockService.baseUrl)/api/users?page=3") else {
				XCTFail("Failed to prepare url!")
				return
			}

			// This is using our API Client implementation in the main target.
			apiClient.makeRequest(toURL: url, withHttpMethod: .get) { results in
				if let data = results.data {
					let decoder = JSONDecoder()
					decoder.keyDecodingStrategy = .convertFromSnakeCase
					guard let userData = try? decoder.decode(UserData.self, from: data) else {
						// There's something with the structure of data either on our end, or how we defined the body we are expecting...
						// Either way, they don't match meaning there's something wrong with our decoder implementation (or model) or body defined in .willRespondWith(...)
						XCTFail("Failed to decode UserData")
						completed() // Notify MockService we're done with our test
						return
					}

					// test the response from server is what we expected and it decodes into userData
					do {
						// Assert the returned random Int is between 0 and 100
						let resultPage = try XCTUnwrap(userData.page)
						XCTAssertTrue((0...100).contains(resultPage))

						// Assert the returned random string is a valid UUID
						// MockServer might return a "simple" UUID (lowercased and
						let resultUUID = try XCTUnwrap(userData.data?.first?.uuid)
						if resultUUID.contains("-") {
							XCTAssertNotNil(UUID(uuidString: resultUUID.uppercased()))
						} else {
							XCTAssertNotNil(resultUUID.uuid)
						}

						// Assert the returned random string is valid date with the specific format we expect it in
						let resultDate = try XCTUnwrap(userData.data?.first?.joined)
						let dateFormatter = DateFormatter()
						dateFormatter.dateFormat = "dd.MM.yyyy"
						XCTAssertNotNil(dateFormatter.date(from: resultDate))
					} catch {
						XCTFail("Failed to test example generators")
					}
				}
				completed() // Notify MockService we're done with our test
			}
		}
	}

}

extension PassingTestsExample: URLSessionDelegate {

	func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		guard
			challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
			(challenge.protectionSpace.host.contains("0.0.0.0") || challenge.protectionSpace.host.contains("localhost")),
			let serverTrust = challenge.protectionSpace.serverTrust
		else {
			completionHandler(.performDefaultHandling, nil)
			return
		}

		let credential = URLCredential(trust: serverTrust)
		completionHandler(.useCredential, credential)
	}

}

private extension String {

	var uuid: UUID? {
		guard !self.contains("-") else {
			return nil
		}

		var str: String = self
		[8, 13, 18, 23].forEach { str.insert("-", at: str.index(str.startIndex, offsetBy: $0)) }

		return UUID(uuidString: str.uppercased())
	}

}

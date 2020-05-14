//
//  Pact_iOS_FAILING_ExampleTests.swift
//  Pact-iOS-FAILING-ExampleTests
//
//  Created by Marko Justinek on 27/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import XCTest
import PactSwift

@testable import Pact_iOS_Example

class XCTestFailingExampleTests: XCTestCase {

	var mockService = MockService(consumer: "failing_iOS_app", provider: "test_provider")

	override func tearDown() {
		mockService.finalize {
			switch $0 {
			case .success: return
			case .failure(let error):
				XCTFail(error.description)
			}
		}
		super.tearDown()
	}

	// Test that the makeRequest() method handles the request and response based on our expectations
	func testGetsUsers() {
		// Expectations
		_ = mockService
			.uponReceiving("A request for a list of users")
			.given("users exist")
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

	func testGetsUsers_Fails_WhenRequestPathInvalid() {
		_ = mockService
			.uponReceiving("Second request for a list of users")
			// These request descriptions must be unique per Pact contract between a consumer and provider.
			// So that when validating on Provider side, or even just going through Pact Broker list of requests you can differentiate between them. Makes sense, doesn't it.
			.given("users exist")
			.withRequest(
				method: .GET,
				path: "/api/users" // this is what we promise we will call
			)
			.willRespondWith(
				status: 200,
				body: userDataResponse
			)

		let apiClient = RestManager()

		// Testing the expectations by running our makeRequest() method,
		// pointing it to the mockService we programmed it just above

		// But! We're going to call invalid path: /user instead of /users!!!
		// This test should fail, because MockService should tell us we're not doing what we promised we will
		// Pact error reason: Missing request - Because we did not call /user 🤷‍♂️
		mockService.run { [unowned self] completed in
			guard let url = URL(string: "\(self.mockService.baseUrl)/api/user") else {
				XCTFail("Failed to prepare url!")
				return
			}

			apiClient.makeRequest(toURL: url, withHttpMethod: .get) { results in
				// we could write expectations here, but this test demonstrates how MockService intercepts our bad code...
				completed() // Notify MockService we're done with our test
			}
		}
	}

	func testGetsUsers_Fails_WhenNoExpectedRequestIsMade() {
		_ = mockService
			.uponReceiving("Third request for a list of users")
			.given("users exist")
			.withRequest(
				method: .GET,
				path: "/api/users"
			)
			.willRespondWith(
				status: 200,
				body: userDataResponse
			)

		mockService.run(waitFor: 1) { completed in
			/*
			Some code that we assume would make the API call we defined in .withRequest()
			Something like:
			apiClient.makeRequest(toURL: url, withHttpMethod: .get) { _ in
				// handling code here //
			}
			*/

			// Let's assume we do call apiClient.makeRequest() but the task.resume() is not called in there...
			// Or something else blocked our apiClient to make the actual call. So no API call is made.
			// So for demo purpouse, let's not make the call here as we did in the above tests.
			// This test should fail because Pact MockService should respond with error saying
			// we didn't make the api call we promised we would:

			completed() // Notify MockService we're done with our test
		}
	}

	func testGetsUsers_Fails_WhenQueryParametersAreMissing() {
		_ = mockService
			.uponReceiving("Third request for a list of users")
			.given("users exist")
			.withRequest(
				method: .POST,
				path: "/api/users",
				query: [
					"states": ["VIC","NSW","TAS"],
					"page": ["2"]
				],
				body: ["name": "John"]
			)
			.willRespondWith(
				status: 201,
				body: userDataResponse
			)

		let apiClient = RestManager()

		mockService.run(waitFor: 1) { completed in
			guard let url = URL(string: "\(self.mockService.baseUrl)/api/users?states=TAS") else {
				XCTFail("Failed to prepare url!")
				return
			}

			// This is using our API Client implementation in the main target.
			apiClient.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
			apiClient.httpBodyParameters.add(value: "John", forKey: "name")

			apiClient.makeRequest(toURL: url, withHttpMethod: .post) { results in
				completed() // Notify MockService we're done with our test
			}
		}
	}

	func testGetsUsers_Fails_WhenHeadersMissmatch() {
		_ = mockService
			.uponReceiving("Fourth request for a list of users")
			.given("users exist")
			.withRequest(
				method: .POST,
				path: "/api/users",
				headers: [
					"Xample": "Demo",
					"Content-Type": "application/json"
				],
				body: [
					"name": "John"
				]
			)
			.willRespondWith(
				status: 201,
				body: userDataResponse
			)

		let apiClient = RestManager()

		mockService.run(waitFor: 1) { completed in
			guard let url = URL(string: "\(self.mockService.baseUrl)/api/users") else {
				XCTFail("Failed to prepare url!")
				return
			}

			// This is using our API Client implementation in the main target.
			apiClient.requestHttpHeaders.add(value: "xample", forKey: "demo-for-you") // We promised we will send "Xample": "Demo"
			apiClient.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
			apiClient.httpBodyParameters.add(value: "John", forKey: "name")

			apiClient.makeRequest(toURL: url, withHttpMethod: .post) { results in
				// No need to handle response in this example, as the request fails because the header we're sending
				// does not match the header we promised we will send... We promised "Xample": "Demo", but sent "xample": "demo-for-you"
				completed() // Notify MockService we're done with our test
			}
		}
	}

	func testGetsUsers_Fails_WhenBodyMissmatch() {
		// Expectations
		_ = mockService
			.uponReceiving("Fifth request for a list of users")
			.given("users exist")
			.withRequest(
				method: .POST,
				path: "/api/users",
				body: [
					"name": "Julia"
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
			//  apiClient.httpBodyParameters.add(value: "John", forKey: "name") // We promised we will send "Julia"
			//  but the `apiClient = RestManager()`, for some reason (bad and buggy implementation), sends `{\n\n}`
			//  when no body is provided but Content-Type set to app/json 🤷‍♂️
			apiClient.makeRequest(toURL: url, withHttpMethod: .post) { results in
				//  No need to handle response in this example, as the request fails because the body we're sending
				//  does not match the body we promised we will send... We promised "name": "Julia"
				completed() // Notify MockService we're done with our test
			}
		}
	}

}

import Foundation
import SWAPIClient

let baseURL = "https://swapi.dev/api"
let apiClient = SWAPIClient(baseURL: baseURL)

// The fetcher

func fetchCharacter(id: Int) {
	let sema = DispatchSemaphore(value: 0)

	apiClient.fetch(endpoint: SWAPIClient.Endpoint.people, id: id) { (result: SWPerson?, error) in

			if let person = result {
					print(person)
			} else {
					print("Failed to fetch a Star Wars Character!")
			}

			sema.signal()

	}

	sema.wait()
}

// Fetch Luke Skywalker
print("Fetching Luke Skywalker (id: 1)")
fetchCharacter(id: 1)

print("")

// Fetch C-3PO
print("Fetching C-3PO (id: 2)")
fetchCharacter(id: 2)

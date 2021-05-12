//
//  SWAPIClient.swift
//  PactMacOSExample
//
//  Created by Marko Justinek on 5/2/21.
//
//  DISCLAIMER:
//
//  This is not how you write good API clients.
//  This is only to demonstrate the minimal required setup to get Pact tests running.
//

import Foundation

class SWAPIClient: NSObject {

	enum Endpoint: String {
		case people
		case planets
		case starships
	}

	let baseURL: String

	private lazy var session = {
		return URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main)
	}()

	init(baseURL: String) {
		self.baseURL = baseURL
	}

	// MARK: - SWAPIClient

	func fetch<D>(endpoint: Endpoint, id: Int? = nil, completion: @escaping (D?, Error?) -> Void) where D: Decodable {
		session
			.decodable(
				for: .makeRequest(url: endpoint.url(baseURL: baseURL, id: id))
			) { (result: Result<D, Error>) in
				switch result {
				case .success(let object): completion(object, nil)
				case .failure(let error): completion(nil, error)
				}
			}
	}

}

private extension SWAPIClient.Endpoint {

	func url(baseURL: String, id: Int? = nil) -> URL {
		// This API client only handles the following endpoints:
		// - https://swapi.dev/api/people/{id?}
		// - https://swapi.dev/api/planets/{id?}
		// - https://swapi.dev/api/starships/{id?}
		//
		if let id = id {
			return URL(string: "\(baseURL)/\(self.rawValue)/\(id)")!
		} else {
			return URL(string: "\(baseURL)/\(self.rawValue)")!
		}
	}

}

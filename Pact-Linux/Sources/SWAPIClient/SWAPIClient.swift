import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class SWAPIClient: NSObject {

	public enum Endpoint: String {
		case people
		case planets
		case starships
	}

	public let baseURL: String

	public init(baseURL: String) {
		self.baseURL = baseURL
	}

	// MARK: - SWAPIClient
	public func fetch<D>(endpoint: Endpoint, id: Int? = nil, completion: @escaping (D?, Error?) -> Void) where D: Decodable {
		URLSession.shared.decodable(
				for: .makeRequest(url: endpoint.url(baseURL: baseURL, id: id))
			) { (result: Result<D, Error>) in
				print("Result: \(result)")
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
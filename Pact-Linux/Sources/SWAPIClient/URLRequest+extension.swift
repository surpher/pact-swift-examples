import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLRequest {

	public static func makeRequest(url: URL, method: HTTPMethod = .GET, body: Data? = nil) -> URLRequest {
		var request = URLRequest(url: url)
		request.setDefaultHeaders()
		request.httpMethod = method.rawValue
		request.httpBody = body

		return request
	}

	public mutating func setDefaultHeaders() {
		Self.defaultHeaders().forEach {
			self.setValue($0.value, forHTTPHeaderField: $0.key)
		}
	}

	public static func defaultHeaders() -> [String: String] {
		[
			"Accept": "application/json",
		]
	}

}
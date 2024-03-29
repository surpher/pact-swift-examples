import Foundation

extension URLRequest {

    static func makeRequest(url: URL, method: HTTPMethod = .GET, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.setDefaultHeaders()
        request.httpMethod = method.rawValue
        request.httpBody = body
        return request
    }

    mutating func setDefaultHeaders() {
        Self.defaultHeaders().forEach {
            self.setValue($0.value, forHTTPHeaderField: $0.key)
        }
    }

    static func defaultHeaders() -> [String: String] {
        [
            "Content-Type": "application/json"
        ]
    }

}

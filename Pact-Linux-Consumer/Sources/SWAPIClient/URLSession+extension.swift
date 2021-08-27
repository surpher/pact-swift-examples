import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLSession {

	public func decodable<D>(for request: URLRequest, completion: @escaping ((Result<D, Error>) -> Void)) where D: Decodable {

		dataTask(with: request) { data, response, error in
			if let error = error {
				completion(.failure(error))
			}

			guard let response = response as? HTTPURLResponse else {
				completion(.failure(SWAPIError.unknown))
				return
			}

			guard (200...299).contains(response.statusCode) else {
				completion(.failure(SWAPIError.statusCode(response.statusCode)))
				return
			}

			guard let data = data else {
				completion(.failure(SWAPIError.missingData))
				return
			}

			do {
				let response = try JSONDecoder().decode(D.self, from: data)
				completion(.success(response))
			} catch {
				completion(.failure(SWAPIError.parsingError))
			}
		}
		.resume()

	}

}
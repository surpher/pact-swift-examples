// Copyright © 2025 Marko Justinek. All rights reserved.

import Foundation

actor APIService {

    func fetch<T: Decodable>(from url: URL, decoding: T.Type) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknownError(code: -1, message: "Invalid response format")
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error.localizedDescription)
            }

        case 400...499:
            throw APIError.clientError(code: httpResponse.statusCode, message: "Client error occurred")

        case 500...599:
            throw APIError.serverError(code: httpResponse.statusCode, message: "Server error occurred")

        default:
            throw APIError.unknownError(code: httpResponse.statusCode, message: "Unexpected error occurred")
        }
    }
}

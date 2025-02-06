// Copyright © 2025 Marko Justinek. All rights reserved.

enum APIError: Error {
    case invalidURL
    case clientError(code: Int, message: String)
    case serverError(code: Int, message: String)
    case unknownError(code: Int, message: String)
    case decodingError(String?)
}

import Foundation

enum AnimalServiceError: Error {

    case missingData
    case unknown
    case statusCode(Int?)
    case parsingError

}

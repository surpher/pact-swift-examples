import Foundation

enum HTTPMethod: String, RawRepresentable {

    case GET
    case POST
    case PATCH
    case PUT
    case DELETE
    // and so on and on
}

extension HTTPMethod: CustomStringConvertible {

    var description: String { rawValue }

}

import Foundation

public enum HTTPMethod: String, RawRepresentable {

	case GET
	case POST
	case PATCH
	case PUT
	case DELETE
	// and so on and on

}

extension HTTPMethod: CustomStringConvertible {

	public var description: String { rawValue }

}
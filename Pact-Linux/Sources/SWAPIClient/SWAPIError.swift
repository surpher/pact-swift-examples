import Foundation

public enum SWAPIError: Error {

	case missingData
	case unknown
	case statusCode(Int?)
	case parsingError

}
//
//  SWAPIError.swift
//  PactMacOSExample
//
//  Created by Marko Justinek on 6/2/21.
//

import Foundation

enum SWAPIError: Error {

	case missingData
	case unknown
	case statusCode(Int?)
	case parsingError

}

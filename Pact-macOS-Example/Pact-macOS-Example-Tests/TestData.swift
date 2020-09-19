//
//  TestData.swift
//  XCTestExampleTests
//
//  Created by Marko Justinek on 23/4/20.
//  Copyright © 2020 Pact Foundation. All rights reserved.
//

import Foundation
import PactSwift

var userDataResponse: Any {
	[
		"page": Matcher.SomethingLike(1),
		"per_page": Matcher.SomethingLike(25),
		"total": Matcher.SomethingLike(1234),
		"total_pages": Matcher.SomethingLike(493),
		"data": [
			[
				"id": Matcher.IntegerLike(1),
				"first_name": Matcher.SomethingLike("John"),
				"last_name": Matcher.SomethingLike("Tester")
				// and we don't care about the avatar 🤷‍♂️
			]
		]
	]
}

var singleUserResponse: Any {
	[
		"data": [
			"id": Matcher.IntegerLike(1),
			"first_name": Matcher.SomethingLike("John"),
			"last_name": Matcher.SomethingLike("Tester")
			// and we don't care about the avatar 🤷‍♂️
		]
	]
}

//  The following was copied from
//  https://github.com/appcoda/RESTful-Demo/blob/master/RestManager/SampleStructures.swift
//
//  SampleStructures.swift
//  RestManager
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

// The structures below map the response objects at https://reqres.in/api/users

var defString = String(stringLiteral: "")
var defInt = -1

struct UserData: Codable, CustomStringConvertible {

	var page: Int?
	var perPage: Int?
	var total: Int?
	var totalPages: Int?
	var data: [User]?

	var description: String {
		var desc = """
		page = \(page ?? defInt)
		records per page = \(perPage ?? defInt)
		total records = \(total ?? defInt)
		total pages = \(totalPages ?? defInt)
		Users:

		"""
		if let users = data {
			for user in users {
				desc += user.description
			}
		}

		return desc
	}

}

struct SingleUserData: Codable {
	var data: User?
}

struct User: Codable, CustomStringConvertible {
	var id: Int?
	var uuid: String?
	var firstName: String?
	var lastName: String?
	var avatar: String?
	var joined: String?

	var description: String {
		return """
		------------
		id = \(id ?? defInt)
		uuid - \(uuid ?? defString)
		firstName = \(firstName ?? defString)
		lastName = \(lastName ?? defString)
		avatar = \(avatar ?? defString)
		joined = \(joined ?? defString)
		------------
		"""
	}
}


struct JobUser: Codable, CustomStringConvertible {
	var id: String?
	var name: String?
	var job: String?
	var createdAt: String?

	var description: String {
		return """
		id = \(id ?? defString)
		name = \(name ?? defString)
		job = \(job ?? defString)
		createdAt = \(createdAt ?? defString)
		"""
	}

}

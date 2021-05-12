//
//  SWCharacter.swift
//  PactMacOSExample
//
//  Created by Marko Justinek on 5/2/21.
//

import Foundation

struct SWPerson {

	let name: String
	let eyeColor: String
	let edited: String
	let birthYear: String

	let films: [String]
	let species: [String]

}

extension SWPerson: Decodable {

	enum CodingKeys: String, CodingKey {
		case name
		case eyeColor = "eye_color"
		case edited
		case birthYear = "birth_year"
		case films
		case species
	}

}

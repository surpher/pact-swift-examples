import Foundation

public struct SWPerson {

	public let name: String
	public let eyeColor: String
	public let edited: String
	public let birthYear: String

	public let films: [String]
	public let species: [String]

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
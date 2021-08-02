import Foundation

struct SWStarshipsList {

	let count: Int
	let results: [SWStarship]

}

extension SWStarshipsList: Decodable {

	enum CodingKeys: String, CodingKey {
		case count
		case results
	}

}
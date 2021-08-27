import Foundation

struct SWStarship {

	let name: String
	let model: String
	let manufacturer: String
	let costInCredits: String
	let length: String
	let maxAtmospheringSpeed: String
	let crew: String
	let passengers: String
	let cargoCapacity: String
	let films: [String]

}

extension SWStarship: Decodable {

	enum CodingKeys: String, CodingKey {
		case name
		case model
		case manufacturer
		case costInCredits = "cost_in_credits"
		case length
		case maxAtmospheringSpeed = "max_atmosphering_speed"
		case crew
		case passengers
		case cargoCapacity = "cargo_capacity"
		case films
	}

}
import Foundation

struct SWPlanet {

	let name: String
	let rotationPeriod: String
	let orbitalPeriod: String
	let diameter: String
	let climate: String
	let gravity: String
	let terrain: String
	let surfaceWater: String
	let residents: [String]

}

extension SWPlanet: Decodable {

	enum CodingKeys: String, CodingKey {
		case name
		case rotationPeriod = "rotation_period"
		case orbitalPeriod = "orbital_period"
		case diameter
		case climate
		case gravity
		case terrain
		case surfaceWater = "surface_water"
		case residents
	}

}
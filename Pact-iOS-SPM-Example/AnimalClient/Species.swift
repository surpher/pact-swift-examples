import Foundation

struct Species: Decodable {

    let id: UUID
    let name: String
    let animals: [Animal]?

}

import Foundation

struct Animal {

    let id: UUID?
    let name: String
    let age: Int

}

extension Animal: Decodable {

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case age
    }

}

import Fluent
import Vapor

final class Species: Model, Content {

    static let schema = "species"

    @ID
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Children(for: \.$species)
    var animals: [Animal]

    init() { }

    init(id: UUID? = nil, name: String) {
    self.name = name
    }

}

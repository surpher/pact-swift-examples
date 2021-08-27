import Fluent
import Vapor

final class Animal: Model, Content {
    static let schema = "animals"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "age")
    var age: Int

    @Parent(key: "speciesID")
    var species: Species

    init() { }

    init(id: UUID? = nil, name: String, age: Int, speciesID: Species.IDValue) {
        self.id = id
        self.name = name
        self.age = age
        self.$species.id = speciesID
    }

}

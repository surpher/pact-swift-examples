import Fluent

struct CreateAnimal: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("animals")
            .id()
            .field("name", .string, .required)
            .field("age", .int, .required)
            .field("speciesID", .uuid, .required, .references("species", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("animals").delete()
    }
}

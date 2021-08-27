import Fluent

struct CreateSpecies: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("species")
            .id()
            .field("name", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("species").delete()
    }
}

import Fluent
import Vapor

struct AnimalController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let routesGroup = routes.grouped("api", "animals")
        routesGroup.get(use: getAllHandler)
        routesGroup.post(use: createHandler)
        routesGroup.get(":animalID", use: getHandler)
        routesGroup.get(":animalID", "species", use: getSpeciesHandler)
        routesGroup.delete(":animalID", use: deleteHandler)
        routesGroup.get("search", ":animalName", use: searchHandler)
    }

    func getAllHandler(_ request: Request) throws -> EventLoopFuture<[Animal]> {
        return Animal
            .query(on: request.db)
            .all()
    }

    func createHandler(_ request: Request) throws -> EventLoopFuture<Animal> {
        let data = try request.content.decode(CreateAnimalData.self)
        let animal = Animal(
            name: data.name,
            age: data.age,
            speciesID: data.speciesID
        )

        return animal
            .save(on: request.db)
            .map { animal }
    }

    func getHandler(_ request: Request) -> EventLoopFuture<Animal> {
        Animal
            .find(request.parameters.get("animalID"), on: request.db)
            .unwrap(or: Abort(.notFound))
    }

    func getSpeciesHandler(_ request: Request) -> EventLoopFuture<Species> {
        Animal
            .find(request.parameters.get("animalID"), on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { animal in
                animal.$species.get(on: request.db)
            }
    }

    func deleteHandler(_ request: Request) -> EventLoopFuture<HTTPStatus> {
        Animal
            .find(request.parameters.get("animalID"), on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { animal in
                animal.delete(on: request.db)
                    .transform(to: .noContent)
            }
    }

    func searchHandler(_ request: Request) throws -> EventLoopFuture<Animal> {
        guard let searchTerm = request.parameters.get("animalName") else {
            throw Abort(.badRequest)
        }

        return Animal
            .query(on: request.db)
            .filter(\.$name, .custom("ILIKE"), searchTerm)
            .first()
            .unwrap(or: Abort(.notFound))
    }

}

struct CreateAnimalData: Content {
    let name: String
    let age: Int
    let speciesID: UUID
}

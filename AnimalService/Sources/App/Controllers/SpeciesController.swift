import Fluent
import Vapor

struct SpeciesController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let routesGroup = routes.grouped("api", "species")

        routesGroup.get(use: getAllHandler)
        routesGroup.post(use: createHandler)
        routesGroup.get(":speciesID", use: getHandler)
        routesGroup.get(":speciesID", "animals", use: getAnimalsHandler)
        routesGroup.delete(":speciesID", use: deleteHandler)
    }

    func getAllHandler(_ request: Request) throws -> EventLoopFuture<[Species]> {
        guard request.query[String.self, at: "showChildren"] != "true" else {
            return getSpeciesWithAnimals(request)
        }

        return Species
            .query(on: request.db)
            .all()
    }

    func createHandler(_ request: Request) throws -> EventLoopFuture<Response> {
        let species = try request.content.decode(Species.self)

        return species
            .save(on: request.db)
            .map { species }
            .encodeResponse(status: .created, for: request)
    }

    func getHandler(_ request: Request) -> EventLoopFuture<Species> {
        Species
            .find(request.parameters.get("speciesID"), on: request.db)
            .unwrap(or: Abort(.notFound))
    }

    func getAnimalsHandler(_ request: Request) -> EventLoopFuture<[Animal]> {
        Species
            .find(request.parameters.get("speciesID"), on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { species in
                species.$animals.get(on: request.db)
            }
    }

    func deleteHandler(_ request: Request) -> EventLoopFuture<HTTPStatus> {
        Species
            .find(request.parameters.get("speciesID"), on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { species in
                species.delete(on: request.db)
                    .transform(to: .noContent)
            }
    }

}

private extension SpeciesController {

    func getSpeciesWithAnimals(_ request: Request) -> EventLoopFuture<[Species]> {
        Species
            .query(on: request.db)
            .with(\.$animals)
            .all()
    }

}

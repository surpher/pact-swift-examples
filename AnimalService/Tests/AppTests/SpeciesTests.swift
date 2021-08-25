@testable import App
import XCTVapor

final class SpeciesTests: XCTestCase {

    let speciesName = "Armadillo"
    let speciesURI = "/api/species"
    var app: Application!

    // MARK: - Setup

    override func setUpWithError() throws {
        try super.setUpWithError()

        app = try Application.testable()
    }

    override func tearDownWithError() throws {
        app.shutdown()

        try super.tearDownWithError()
    }

    // MARK: - Tests

    func testSpeciesList() throws {
        // Create two species
        let species = try Species.create(name: speciesName, on: app.db)
        _ = try Species.create(on: app.db)

        // test
        try app.test(.GET, speciesURI) { response in
            XCTAssertTrue((200..<300).contains(response.status.code))

            let speciesSet = try response.content.decode([Species].self)

            XCTAssertEqual(speciesSet.count, 2)
            XCTAssertEqual(speciesSet[0].id, species.id)
            XCTAssertEqual(speciesSet[0].name, speciesName)
        }
    }

    func testCreatesSpecies() throws {
        let species = Species(name: speciesName)

        try app.test(
            .POST, speciesURI,
            headers: HTTPHeaders([("Content-Type", "application/json")]),
            body: nil,
            beforeRequest: { request in try request.content.encode(species) },
            afterResponse: { response in
                let result = try response.content.decode(Species.self)

                XCTAssertEqual(result.name, speciesName)
                XCTAssertNotNil(result.id)

                try app.test(.GET, speciesURI) { secondResponse in
                    let secondResult = try secondResponse.content.decode([Species].self)
                    XCTAssertEqual(secondResult.count, 1)
                    XCTAssertEqual(secondResult[0].name, speciesName)
                    XCTAssertEqual(secondResult[0].id, result.id)
                }
            }
        )
    }

    func testASingleSpecies() throws {
        let species = try Species.create(name: speciesName, on: app.db)

        try app.test(.GET, "\(speciesURI)/\(species.id!)") { response in
            let result = try response.content.decode(Species.self)

            XCTAssertEqual(result.name, speciesName)
            XCTAssertEqual(result.id, species.id)
        }
    }

}

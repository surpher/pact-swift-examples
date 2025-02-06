// Copyright © 2025 Marko Justinek. All rights reserved.

import PactSwift
import XCTest

@testable import Pact_Concurrency

final class Pact_ConcurrencyTests: XCTestCase {

    var builder: PactBuilder!

    @MainActor
    class override func setUp() {
        super.setUp()
        try! Logging.initialize(
            [
                Logging.Sink.Config(.standardError, filter: .trace),
            ]
        )
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        guard builder == nil else {
            return
        }

        let pact = try Pact(consumer: "AppConsumer", provider: "APIProvider")
            .withSpecification(.v4)

        let config = PactBuilder.Config(pactDirectory: Utils.getProjectRoot().appending("/tmp"))
        builder = PactBuilder(pact: pact, config: config)
    }

    // MARK: - Tests

    func testGET() async throws {
        try builder
            .uponReceiving("A GET request")
            .given(
                Interaction.ProviderState(
                    description: "String",
                    name: #file,
                    value: #function
                )
            )
            .withRequest(method: .GET, path: "/hello")
            .willRespond(with: 200) { response in
                try response.jsonBody(
                    .like(["hello":"World!"])
                )
            }

        try await builder
            .verify { context in
                let apiService = APIService()
                let foo = try await apiService.fetch(from: URL(string: "\(context.mockServerURL)/hello")!, decoding: Foo.self)

                XCTAssertEqual(Foo(hello: "World!"), foo)
            }
    }
}

struct Foo: Decodable, Equatable {
    let hello: String
}

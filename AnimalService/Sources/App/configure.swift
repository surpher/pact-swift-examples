import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // testing
    let databaseName: String
    let databasePort: Int

    if (app.environment == .testing) {
        databaseName = "vapor-test"
        databasePort = 5443
    } else {
        databaseName = "vapor"
        databasePort = 5432
    }

    // App
    app.databases.use(
        .postgres(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: databasePort,
            username: Environment.get("DATABASE_USERNAME") ?? "vapor",
            password: Environment.get("DATABASE_PASSWORD") ?? "password",
            database: Environment.get("DATABASE_NAME") ?? databaseName
        ),
        as: .psql
    )

    app.migrations.add(CreateSpecies())
    app.migrations.add(CreateAnimal())

    app.logger.logLevel = .debug

    try app.autoMigrate().wait()

    // register routes
    try routes(app)
}

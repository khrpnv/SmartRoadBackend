import FluentPostgreSQL
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  // Register providers first
  try services.register(FluentPostgreSQLProvider())
  
  // Configure the authentication provider
  try services.register(AuthenticationProvider())
  
  // Register routes to the router
  let router = EngineRouter.default()
  try routes(router)
  services.register(router, as: Router.self)
  
  // Register middleware
  var middlewares = MiddlewareConfig()
  let corsConfiguration = CORSMiddleware.Configuration(
      allowedOrigin: .all,
      allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
      allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
  )
  let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
  middlewares.use(corsMiddleware)
  middlewares.use(ErrorMiddleware.self)
  services.register(middlewares)
  
  // Configure a database
  var databases = DatabasesConfig()
  let databaseName: String
  let databasePort: Int
  if env == .testing {
    databaseName = "vapor-test"
    databasePort = 5433
  } else {
    databaseName = "vapor"
    databasePort = 5432
  }
  let databaseConfig = PostgreSQLDatabaseConfig(
    hostname: "localhost",
    port: databasePort,
    username: "vapor",
    database: databaseName,
    password: "password")
  let database = PostgreSQLDatabase(config: databaseConfig)
  databases.add(database: database, as: .psql)
  services.register(databases)
  
  // Configure migrations
  var migrations = MigrationConfig()
  migrations.add(model: ServiceType.self, database: .psql)
  migrations.add(model: ServiceStation.self, database: .psql)
  migrations.add(model: Road.self, database: .psql)
  migrations.add(model: RoadSensor.self, database: .psql)
  migrations.add(model: Sensor.self, database: .psql)
  migrations.add(model: User.self, database: .psql)
  services.register(migrations)
  
  // Manuall run of migrations
  var commandConfig = CommandConfig.default()
  commandConfig.useFluentCommands()
  services.register(commandConfig)
}

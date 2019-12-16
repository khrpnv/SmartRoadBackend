import Vapor
import FluentPostgreSQL

final class ServiceStation: Codable {
  var id: UUID?
  var name: String
  var description: String
  var latitude: Double
  var longtitude: Double
  var type: Int
  
  init(name: String, description: String, latitude: Double, longtitude: Double, type: Int) {
    self.name = name
    self.description = description
    self.latitude = latitude
    self.longtitude = longtitude
    self.type = type
  }
}

// MARK: - Fluent Protocols
extension ServiceStation: PostgreSQLUUIDModel {}
extension ServiceStation: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
      builder.reference(from: \.type, to: \ServiceType.id)
    }
  }
}
extension ServiceStation: Content {}
extension ServiceStation: Parameter {}

// MARK: - Relationships
extension ServiceStation {
  var sensors: Children<ServiceStation, Sensor> {
    return children(\.ownerId)
  }
  
  var serviceType: Parent<ServiceStation, ServiceType> {
    return parent(\.type)
  }
}

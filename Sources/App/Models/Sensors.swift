import Vapor
import FluentPostgreSQL

final class Sensor: Codable {
  var id: UUID?
  var isEmptyPlace: Bool
  let ownerId: UUID
  
  init(isEmptyPlace: Bool, ownerId: UUID) {
    self.isEmptyPlace = isEmptyPlace
    self.ownerId = ownerId
  }
}

// MARK: - Fluent protocols
extension Sensor: PostgreSQLUUIDModel {}
extension Sensor: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
      builder.reference(from: \.ownerId, to: \ServiceStation.id)
    }
  }
}
extension Sensor: Content {}
extension Sensor: Parameter {}

// MARK: - Relationships
extension Sensor {
  var serviceStation: Parent<Sensor, ServiceStation> {
    return parent(\.ownerId)
  }
}

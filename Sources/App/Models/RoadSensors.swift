import Vapor
import FluentPostgreSQL

final class RoadSensor: Codable {
  var id: UUID?
  var isOverlaped: Bool
  let roadId: UUID
  var amountOfStateChanges: Int
  
  init(isOverlaped: Bool, roadId: UUID, amountOfStateChanges: Int) {
    self.isOverlaped = isOverlaped
    self.roadId = roadId
    self.amountOfStateChanges = amountOfStateChanges
  }
}

// MARK: - Fluent protocols
extension RoadSensor: PostgreSQLUUIDModel {}
extension RoadSensor: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
      builder.reference(from: \.roadId, to: \Road.id)
    }
  }
}
extension RoadSensor: Content {}
extension RoadSensor: Parameter {}

// MARK: - Relationships
extension RoadSensor {
  var road: Parent<RoadSensor, Road> {
    return parent(\.roadId)
  }
}


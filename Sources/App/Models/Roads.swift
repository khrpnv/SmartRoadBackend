import Vapor
import FluentPostgreSQL

final class Road: Codable {
  var id: UUID?
  var address: String
  var length: Double
  var description: String
  var maxAllowedSpeed: Int
  var amountOfLines: Int
  var bandwidth: Int
  
  init(address: String, description: String, maxAllowedSpeed: Int, amountOfLines: Int, length: Double, bandwidth: Int) {
    self.address = address
    self.description = description
    self.maxAllowedSpeed = maxAllowedSpeed
    self.amountOfLines = amountOfLines
    self.length = length
    self.bandwidth = bandwidth
  }
}

// MARK: - Fluent Protocols
extension Road: PostgreSQLUUIDModel {}
extension Road: Migration {}
extension Road: Content {}
extension Road: Parameter {}

// MARK: - Relationships
extension Road {
  var sensors: Children<Road, RoadSensor> {
    return children(\.roadId)
  }
}


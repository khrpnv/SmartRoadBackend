import Vapor
import FluentPostgreSQL

final class ServiceType: Codable {
  var id: Int?
  var typeName: String
  
  init(typeName: String) {
    self.typeName = typeName
  }
}

// MARK: - Fluent Protocols
extension ServiceType: PostgreSQLModel {}
extension ServiceType: Migration {}
extension ServiceType: Content {}
extension ServiceType: Parameter {}

// MARK: - Relationships
extension ServiceType {
  var facilities: Children<ServiceType, ServiceStation> {
    return children(\.type)
  }
}

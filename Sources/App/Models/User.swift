import Foundation
import Vapor
import FluentPostgreSQL
import Fluent
import Authentication

// MARK: - User class
final class User: Codable {
  var id: UUID?
  private(set) var email: String
  private(set) var password: String
  
  init(email: String, password: String) {
    self.email = email
    self.password = password
  }
}

// MARK: - Fluent Protocols
extension User: Content {}
extension User: PostgreSQLUUIDModel {}
extension User: Migration {}
extension User: Parameter {}

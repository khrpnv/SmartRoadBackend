import Vapor
import Fluent
import Crypto

struct UsersController: RouteCollection {
  func boot(router: Router) throws {
    let usersRoutes = router.grouped("api", "users")
    usersRoutes.post(User.self, at: "register", use: registerUserHandler)
    usersRoutes.post(User.self, at: "login", use: login)
    usersRoutes.get("logout", use: logout)
    usersRoutes.get("emails", use: getAllUsersEmails)
    usersRoutes.delete(User.parameter, use: deleteHandler)
  }
  
  // MARK: - Register
  func registerUserHandler(_ request: Request, newUser: User) throws -> Future<HTTPResponseStatus> {
    return User.query(on: request).filter(\.email == newUser.email).first().flatMap { existingUser in
      guard existingUser == nil else {
        throw Abort(.badRequest, reason: "A user with this email already exists" , identifier: nil)
      }
      guard newUser.email.count > 0 && newUser.password.count > 0 else {
        throw Abort(.badRequest, reason: "Empty user data" , identifier: nil)
      }
      let digest = try request.make(BCryptDigest.self)
      let hashedPassword = try digest.hash(newUser.password)
      let persistedUser = User(email: newUser.email, password: hashedPassword)
      return persistedUser.save(on: request).transform(to: .created)
    }
  }
  
  // MARK: - Login
  func login(_ request: Request, user: User) throws -> Future<HTTPResponseStatus> {
    return User.query(on: request).filter(\.email == user.email).first().flatMap { currentUser in
      guard user.email.count > 0 && user.password.count > 0 else {
        throw Abort(.badRequest, reason: "Empty user data" , identifier: nil)
      }
      guard currentUser != nil else {
        throw Abort(.badRequest, reason: "A user with this email doesn't exists" , identifier: nil)
      }
      let digest = try request.make(BCryptDigest.self)
      let isRightPassword = try digest.verify(user.password, created: currentUser!.password)
      if !isRightPassword {
        throw Abort(.badRequest, reason: "Wrong password" , identifier: nil)
      }
      return request.future(HTTPResponseStatus(statusCode: 200, reasonPhrase: "Authorization suceeded"))
    }
  }
  
  // MARK: - Logout
  func logout(_ request: Request) throws -> Future<HTTPResponseStatus> {
    return request.future(HTTPResponseStatus(statusCode: 200))
  }
  
  // MARK: - Read
  func getAllUsersEmails(_ request: Request) throws -> Future<[String]> {
    return User.query(on: request).all().flatMap { users in
      return request.future(users.compactMap({ "\($0.email) - \(String(describing: $0.id))" }))
    }
  }
  
  // MARK: - Delete
  func deleteHandler(_ request: Request) throws -> Future<HTTPStatus> {
    return try request
      .parameters
      .next(User.self)
      .delete(on: request)
      .transform(to: .noContent)
  }
}



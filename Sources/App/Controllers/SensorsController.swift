import Vapor
import Fluent

struct SensorsController: RouteCollection {
  func boot(router: Router) throws {
    let sensorsRoutes = router.grouped("api", "sensors")
    sensorsRoutes.get(use: getAllHandler)
    sensorsRoutes.post(use: createHandler)
    sensorsRoutes.post("update", Sensor.parameter, use: changeStateHandler)
    sensorsRoutes.delete(Sensor.parameter, use: deleteHanlder)
  }
  
  // MARK: - Read
  func getAllHandler(_ request: Request) throws -> Future<[Sensor]> {
    return Sensor.query(on: request).all()
  }
  
  // MARK: - Create
  func createHandler(_ request: Request) throws -> Future<Sensor> {
    return try request
      .content
      .decode(Sensor.self)
      .flatMap(to: Sensor.self, { sensor in
        return sensor.save(on: request)
      })
  }
  
  // MARK: - Update
  func changeStateHandler(_ request: Request) throws -> Future<Sensor> {
    guard let newValue = request.query[Bool.self, at: "state"] else {
      throw Abort(.badRequest)
    }
    return try request.parameters.next(Sensor.self).flatMap({ sensor in
      sensor.isEmptyPlace = newValue
      return sensor.save(on: request)
    })
  }
  
  // MARK: - Delete
  func deleteHanlder(_ request: Request) throws -> Future<HTTPStatus> {
    return try request
      .parameters
      .next(Sensor.self)
      .delete(on: request)
      .transform(to: .noContent)
  }
}

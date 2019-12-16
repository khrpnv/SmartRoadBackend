import Vapor
import Fluent

struct RoadSensorsController: RouteCollection {
  func boot(router: Router) throws {
    let roadSensorsRoutes = router.grouped("api", "road_sensors")
    roadSensorsRoutes.get(use: getAllHandler)
    roadSensorsRoutes.get(RoadSensor.parameter, use: getRoadSensorById)
    roadSensorsRoutes.post("reset", RoadSensor.parameter, use: resetAmountHandler)
    roadSensorsRoutes.post("update", RoadSensor.parameter, use: increaseAmountHandler)
    roadSensorsRoutes.post(use: createHandler)
    roadSensorsRoutes.delete(RoadSensor.parameter, use: deleteHanlder)
  }
  
  // MARK: - Read
  func getAllHandler(_ request: Request) throws -> Future<[RoadSensor]> {
    return RoadSensor.query(on: request).all()
  }
  
  func getRoadSensorById(_ request: Request) throws -> Future<RoadSensor> {
    return try request.parameters.next(RoadSensor.self)
  }
  
  // MARK: - Create
  func createHandler(_ request: Request) throws -> Future<RoadSensor> {
    return try request
      .content
      .decode(RoadSensor.self)
      .flatMap(to: RoadSensor.self, { sensor in
        return sensor.save(on: request)
      })
  }
  
  // MARK: - Update
  func resetAmountHandler(_ request: Request) throws -> Future<RoadSensor> {
    return try request.parameters.next(RoadSensor.self).flatMap { roadSensor in
      roadSensor.amountOfStateChanges = 0
      return roadSensor.save(on: request)
    }
  }
  
  func increaseAmountHandler(_ request: Request) throws -> Future<RoadSensor> {
    guard let newValue = request.query[Bool.self, at: "state"] else {
      throw Abort(.badRequest)
    }
    return try request.parameters.next(RoadSensor.self).flatMap({ roadSensor in
      if roadSensor.isOverlaped == true && newValue == false {
        roadSensor.amountOfStateChanges += 1
      }
      roadSensor.isOverlaped = newValue
      return roadSensor.save(on: request)
    })
  }
  
  // MARK: - Delete
  func deleteHanlder(_ request: Request) throws -> Future<HTTPStatus> {
    return try request
      .parameters
      .next(RoadSensor.self)
      .delete(on: request)
      .transform(to: .noContent)
  }
}


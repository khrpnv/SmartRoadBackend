import Vapor
import Fluent

struct RoadsController: RouteCollection {
  func boot(router: Router) throws {
    let roadsRoutes = router.grouped("api", "roads")
    roadsRoutes.get(use: getAllHandler)
    roadsRoutes.get(Road.parameter, use: getRoadById)
    roadsRoutes.get(Road.parameter, "sensors", use: getAllSensorsForRoad)
    roadsRoutes.get(Road.parameter, "state", use: getRoadState)
    roadsRoutes.post(use: createHandler)
    roadsRoutes.put(Road.parameter, use: updateHandler)
    roadsRoutes.delete(Road.parameter, use: deleteHanlder)
  }
  
  // MARK: - Create
  func createHandler(_ request: Request) throws -> Future<Road> {
    return try request
      .content
      .decode(Road.self)
      .flatMap(to: Road.self, { road in
        road.save(on: request)
      })
  }
  
  // MARK: - Read
  func getAllHandler(_ request: Request) throws -> Future<[Road]> {
    return Road.query(on: request).all()
  }
  
  func getAllSensorsForRoad(_ request: Request) throws -> Future<[RoadSensor]> {
    return try request.parameters.next(Road.self)
    .flatMap(to: [RoadSensor].self, { road in
      return try road.sensors.query(on: request).all()
    })
  }
  
  func getRoadState(_ request: Request) throws -> Future<String> {
    return try request.parameters.next(Road.self)
      .flatMap({ road in
        return try road.sensors.query(on: request)
          .all()
          .map({ roadSensors in
            return RoadStateObserver.roadState(sensors: roadSensors, availability: road.bandwidth)
          })
      })
  }
  
  func getRoadById(_ request: Request) throws -> Future<Road> {
    return try request.parameters.next(Road.self)
  }
  
  // MARK: - Update
  func updateHandler(_ request: Request) throws -> Future<Road> {
    return try flatMap(
      to: Road.self,
      request.parameters.next(Road.self),
      request.content.decode(Road.self),
      { road, updatedRoad in
        road.address = updatedRoad.address
        road.amountOfLines = updatedRoad.amountOfLines
        road.bandwidth = updatedRoad.bandwidth
        road.description = updatedRoad.description
        road.length = updatedRoad.length
        road.maxAllowedSpeed = updatedRoad.maxAllowedSpeed
        return road.save(on: request)
    })
  }
  
  // MARK: - Delete
  func deleteHanlder(_ request: Request) throws -> Future<HTTPStatus> {
    return try request
      .parameters
      .next(Road.self)
      .delete(on: request)
      .transform(to: .noContent)
  }
}


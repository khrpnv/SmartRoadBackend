import Vapor
import Fluent

struct ServiceStationsController: RouteCollection {
  func boot(router: Router) throws {
    let serviceStationsRoutes = router.grouped("api", "service_stations")
    serviceStationsRoutes.get(use: getAllHandler)
    serviceStationsRoutes.get(ServiceStation.parameter, use: getServiceStationById)
    serviceStationsRoutes.post(use: createHandler)
    serviceStationsRoutes.get(ServiceStation.parameter, "sensors", use: getAllSensorsForStationHandler)
    serviceStationsRoutes.get(ServiceStation.parameter, "sensors", "empty", use: getEmptySensorsForStationHandler)
    serviceStationsRoutes.get(ServiceStation.parameter, "type", use: getServiceType)
    serviceStationsRoutes.get("nearest", use: getNearestStations)
    serviceStationsRoutes.put(ServiceStation.parameter, use: updateHandler)
    serviceStationsRoutes.delete(ServiceStation.parameter, use: deleteHanlder)
  }
  
  // MARK: - Read
  func getAllHandler(_ request: Request) throws -> Future<[ServiceStation]> {
    return ServiceStation.query(on: request).all()
  }
  
  func getServiceStationById(_ request: Request) throws -> Future<ServiceStation> {
    return try request.parameters.next(ServiceStation.self)
  }
  
  func getAllSensorsForStationHandler(_ request: Request) throws -> Future<[Sensor]> {
    return try request.parameters.next(ServiceStation.self)
      .flatMap(to: [Sensor].self, { serviceStation in
        return try serviceStation.sensors.query(on: request).all()
      })
  }
  
  func getEmptySensorsForStationHandler(_ request: Request) throws -> Future<[Sensor]> {
    return try request.parameters.next(ServiceStation.self)
    .flatMap(to: [Sensor].self, { serviceStation in
      return try serviceStation.sensors.query(on: request).filter(\.isEmptyPlace == true).all()
    })
  }
  
  func getServiceType(_ request: Request) throws -> Future<ServiceType> {
    return try request.parameters.next(ServiceStation.self)
      .flatMap(to: ServiceType.self, { serviceStation in
        return serviceStation.serviceType.get(on: request)
      })
  }
  
  func getNearestStations(_ request: Request) throws -> Future<[ServiceStation]> {
    guard
      let currentLat = request.query[Double.self, at: "lat"],
      let currentLong = request.query[Double.self, at: "long"],
      let currentTypeIndex = request.query[Int.self, at: "type"],
      let range = request.query[Int.self, at: "range"]
      else {
        throw Abort(.badRequest)
    }
    return ServiceStation.query(on: request).all().map { serviceStation in
      return serviceStation.filter {
        DistanceCalculator.countDistance(startLat: currentLat,
                                         startLong: currentLong,
                                         endLat: $0.latitude,
                                         endLong: $0.longtitude) <= Double(range) && currentTypeIndex == $0.type
      }
    }
  }
  
  // MARK: - Create
  func createHandler(_ request: Request) throws -> Future<ServiceStation> {
    return try request
      .content
      .decode(ServiceStation.self)
      .flatMap(to: ServiceStation.self, { serviceStation in
        serviceStation.save(on: request)
      })
  }
  
  // MARK: - Update
  func updateHandler(_ request: Request) throws -> Future<ServiceStation> {
    return try flatMap(
      to: ServiceStation.self,
      request.parameters.next(ServiceStation.self),
      request.content.decode(ServiceStation.self),
      { station, updatedStation in
        station.name = updatedStation.name
        station.description = updatedStation.description
        station.latitude = updatedStation.latitude
        station.longtitude = updatedStation.longtitude
        return station.save(on: request)
    })
  }
  
  // MARK: - Delete
  func deleteHanlder(_ request: Request) throws -> Future<HTTPStatus> {
    return try request
      .parameters
      .next(ServiceStation.self)
      .delete(on: request)
      .transform(to: .noContent)
  }
}

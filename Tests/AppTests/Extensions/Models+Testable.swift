@testable import App
import FluentPostgreSQL

extension App.ServiceType {
  static func create(typeName: String = "Car wash", on connection: PostgreSQLConnection) throws -> App.ServiceType {
    let serviceType = App.ServiceType(typeName: typeName)
    return try serviceType.save(on: connection).wait()
  }
}

extension ServiceStation {
  static func create(name: String = "Autofix",
                     description: String = "---------",
                     latitude: Double = 34.544543,
                     longtitude: Double = 48.390892,
                     serviceType: App.ServiceType? = nil,
                     on connection: PostgreSQLConnection) throws -> ServiceStation {
    var serviceStationType = serviceType
    
    if serviceStationType == nil {
      serviceStationType = try App.ServiceType.create(on: connection)
    }
    
    let serviceStation = ServiceStation(name: name,
                                        description: description,
                                        latitude: latitude,
                                        longtitude: longtitude,
                                        type: serviceStationType!.id!)
    return try serviceStation.save(on: connection).wait()
  }
}

extension Sensor {
  static func create(isemptyPlace: Bool = true,
                     serviceStation: ServiceStation? = nil,
                     on connection: PostgreSQLConnection) throws -> Sensor {
    var sensorServiceStation = serviceStation
    
    if sensorServiceStation == nil {
      sensorServiceStation = try ServiceStation.create(on: connection)
    }
    
    let sensor = Sensor(isEmptyPlace: isemptyPlace, ownerId: sensorServiceStation!.id!)
    return try sensor.save(on: connection).wait()
  }
}

extension Road {
  static func create(addres: String = "Naukova av.",
                     description: String = "----",
                     maxAllowedSpeed: Int = 60,
                     amountOfLines: Int = 3,
                     length: Double = 55.5,
                     bandwidth: Int = 90,
                     on connection: PostgreSQLConnection) throws -> Road {
    let road = Road(address: addres,
                    description: description,
                    maxAllowedSpeed: maxAllowedSpeed,
                    amountOfLines: amountOfLines,
                    length: length,
                    bandwidth: bandwidth)
    return try road.save(on: connection).wait()
  }
}

extension RoadSensor {
  static func create(isOverlaped: Bool = false,
                     road: Road? = nil,
                     amountOfStateChanges: Int = 0,
                     on connection: PostgreSQLConnection) throws -> RoadSensor {
    var sensorRoad = road
    
    if sensorRoad == nil {
      sensorRoad = try Road.create(on: connection)
    }
    let roadSensor = RoadSensor(isOverlaped: isOverlaped, roadId: sensorRoad!.id!, amountOfStateChanges: amountOfStateChanges)
    return try roadSensor.save(on: connection).wait()
  }
}

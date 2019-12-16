@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class ServiceStationTests: XCTestCase {
  let stationName = "Autofix"
  let stationDescription = "------"
  let latitude: Double = 45.453
  let longtitude: Double = 38.3434
  let stationURL = "/api/service_stations/"
  var app: Application!
  var conn: PostgreSQLConnection!
  
  override func setUp() {
    try! Application.reset()
    app = try! Application.testable()
    conn = try! app.newConnection(to: .psql).wait()
  }
  
  override func tearDown() {
    conn.close()
    try? app.syncShutdownGracefully()
  }
  
  func testStationsCanBeRetrievedFromAPI() throws {
    let station = try ServiceStation.create(
      name: stationName,
      description: stationDescription,
      latitude: latitude,
      longtitude: longtitude,
      on: conn)
    _ = try ServiceStation.create(on: conn)

    let stations = try app.getResponse(to: stationURL, decodeTo: [ServiceStation].self)

    XCTAssertEqual(stations.count, 2)
    XCTAssertEqual(stations[0].id, station.id)
    XCTAssertEqual(stations[0].name, station.name)
    XCTAssertEqual(stations[0].description, station.description)
    XCTAssertEqual(stations[0].latitude, station.latitude)
    XCTAssertEqual(stations[0].longtitude, station.longtitude)
    XCTAssertEqual(stations[0].type, station.type)
  }
  
  func testSingleStationTypeCanBeRetrievedFromAPI() throws {
    let station = try ServiceStation.create(
    name: stationName,
    description: stationDescription,
    latitude: latitude,
    longtitude: longtitude,
    on: conn)
    let returnedStation = try app.getResponse(to: "\(stationURL)\(station.id!)", decodeTo: ServiceStation.self)
    
    XCTAssertEqual(station.id, returnedStation.id)
    XCTAssertEqual(station.id, returnedStation.id)
    XCTAssertEqual(station.name, returnedStation.name)
    XCTAssertEqual(station.description, returnedStation.description)
    XCTAssertEqual(station.latitude, returnedStation.latitude)
    XCTAssertEqual(station.longtitude, returnedStation.longtitude)
    XCTAssertEqual(station.type, returnedStation.type)
  }
  
  func testStationCanBeSavedWithAPI() throws {
    let station = try ServiceStation.create(
    name: stationName,
    description: stationDescription,
    latitude: latitude,
    longtitude: longtitude,
    on: conn)

    let recievedStation = try app.getResponse(
      to: stationURL,
      method: .POST,
      headers: ["Content-Type": "application/json"],
      data: station,
      decodeTo: ServiceStation.self)

    XCTAssertNotNil(recievedStation.id)

    let stations = try app.getResponse(to: stationURL, decodeTo: [ServiceStation].self)

    XCTAssertEqual(stations.count, 1)
    XCTAssertEqual(stations[0].id, recievedStation.id)
    XCTAssertEqual(stations[0].name, recievedStation.name)
    XCTAssertEqual(stations[0].description, recievedStation.description)
    XCTAssertEqual(stations[0].latitude, recievedStation.latitude)
    XCTAssertEqual(stations[0].longtitude, recievedStation.longtitude)
    XCTAssertEqual(stations[0].type, recievedStation.type)
  }
  
  func testGettingAServiceStationSensorsFromAPI() throws {
    let station = try ServiceStation.create(
    name: stationName,
    description: stationDescription,
    latitude: latitude,
    longtitude: longtitude,
    on: conn)
    
    let sensorState = true
    
    let sensor = try Sensor.create(isemptyPlace: sensorState, serviceStation: station, on: conn)
    _ = try Sensor.create(isemptyPlace: false, serviceStation: station, on: conn)
    
    let sensors = try app.getResponse(to: "\(stationURL)\(station.id!)/sensors", decodeTo: [Sensor].self)
    
    XCTAssertEqual(sensors.count, 2)
    XCTAssertEqual(sensors[0].id, sensor.id)
    XCTAssertEqual(sensors[0].isEmptyPlace, sensorState)
  }
  
  func testGettingAServiceStationEmptySensorsFromAPI() throws {
    let station = try ServiceStation.create(
    name: stationName,
    description: stationDescription,
    latitude: latitude,
    longtitude: longtitude,
    on: conn)
    
    let firstEmptySensor = try Sensor.create(isemptyPlace: true, serviceStation: station, on: conn)
    _ = try Sensor.create(isemptyPlace: false, serviceStation: station, on: conn)
    let secondEmptySensor = try Sensor.create(isemptyPlace: true, serviceStation: station, on: conn)
    
    let sensors = try app.getResponse(to: "\(stationURL)\(station.id!)/sensors/empty", decodeTo: [Sensor].self)
    
    XCTAssertEqual(sensors.count, 2)
    XCTAssertEqual(sensors[0].id, firstEmptySensor.id)
    XCTAssertEqual(sensors[0].isEmptyPlace, true)
    XCTAssertEqual(sensors[1].isEmptyPlace, true)
    XCTAssertEqual(sensors[1].id, secondEmptySensor.id)
  }
  
  func testGettingAServiceStationTypeFromAPI() throws {
    let serviceType = try App.ServiceType.create(typeName: "Car wash", on: conn)
    let station = try ServiceStation.create(
    name: stationName,
    description: stationDescription,
    latitude: latitude,
    longtitude: longtitude,
    serviceType: serviceType,
    on: conn)
    
    let returnedType = try app.getResponse(to: "\(stationURL)\(station.id!)/type", decodeTo: ServiceType.self)
    
    XCTAssertEqual(returnedType.id, serviceType.id)
    XCTAssertEqual(returnedType.typeName, serviceType.typeName)
  }
  
  func testGettingNearestStationsByParameters() throws {
    let serviceType = try App.ServiceType.create(typeName: "Car wash", on: conn)
    let station = try ServiceStation.create(
    name: stationName,
    description: stationDescription,
    latitude: latitude - 0.00002,
    longtitude: longtitude - 0.0003,
    serviceType: serviceType,
    on: conn)
    
    _ = try ServiceStation.create(
    name: "Speed fix",
    description: "_______",
    latitude: latitude,
    longtitude: longtitude,
    serviceType: serviceType,
    on: conn)
    
    _ = try ServiceStation.create(
    name: "Fix right now",
    description: "_______",
    latitude: latitude - 1.0,
    longtitude: longtitude - 1.0,
    serviceType: serviceType,
    on: conn)
    
    let urlString = "\(stationURL)/nearest?lat=\(station.latitude)&long=\(station.longtitude)&type=\(serviceType.id!)&range=5"
    let returnedStations = try app.getResponse(to: urlString, decodeTo: [ServiceStation].self)
    
    XCTAssertEqual(returnedStations.count, 2)
    XCTAssertEqual(returnedStations[0].id, station.id)
    XCTAssertEqual(returnedStations[0].name, station.name)
    XCTAssertEqual(returnedStations[0].description, station.description)
    XCTAssertEqual(returnedStations[0].latitude, station.latitude)
    XCTAssertEqual(returnedStations[0].longtitude, station.longtitude)
    XCTAssertEqual(returnedStations[0].type, serviceType.id)
  }
  
  func testDeletingStations() throws {
    let station = try ServiceStation.create(on: conn)
    var stations = try app.getResponse(to: stationURL, decodeTo: [ServiceStation].self)
    
    XCTAssertEqual(stations.count, 1)
    
    _ = try app.sendRequest(to: "\(stationURL)\(station.id!)", method: .DELETE)
    stations = try app.getResponse(to: stationURL, decodeTo: [ServiceStation].self)
    
    XCTAssertEqual(stations.count, 0)
  }
  
  func testServiceTypeCanBeUpdated() throws {
    let serviceType = try App.ServiceType.create(typeName: "Car wash", on: conn)
    
    let station = try ServiceStation.create(
    name: stationName,
    description: stationDescription,
    latitude: latitude - 0.00002,
    longtitude: longtitude - 0.0003,
    serviceType: serviceType,
    on: conn)
    
    let newName = "Fast car recover"
    let newDescription = "Description"
    let newLat = 44.66
    let newLong = 53.554
    
    
    _ = try app.getResponse(
      to: "\(stationURL)\(station.id!)",
      method: .PUT,
      headers: ["Content-Type": "application/json"],
      data: ServiceStation(name: newName,
                           description: newDescription,
                           latitude: newLat,
                           longtitude: newLong, type: serviceType.id!),
      decodeTo: ServiceStation.self)
    
    let returnedType = try app.getResponse(to: "\(stationURL)\(station.id!)", decodeTo: ServiceStation.self)
    
    XCTAssertEqual(returnedType.id, station.id)
    XCTAssertEqual(returnedType.name, newName)
    XCTAssertEqual(returnedType.description, newDescription)
    XCTAssertEqual(returnedType.latitude, newLat)
    XCTAssertEqual(returnedType.longtitude, newLong)
  }
  
  static let allTests = [
    ("testStationsCanBeRetrievedFromAPI", testStationsCanBeRetrievedFromAPI),
    ("testSingleStationTypeCanBeRetrievedFromAPI", testSingleStationTypeCanBeRetrievedFromAPI),
    ("testStationCanBeSavedWithAPI", testStationCanBeSavedWithAPI),
    ("testGettingAServiceStationSensorsFromAPI", testGettingAServiceStationSensorsFromAPI),
    ("testGettingAServiceStationEmptySensorsFromAPI", testGettingAServiceStationEmptySensorsFromAPI),
    ("testGettingAServiceStationTypeFromAPI", testGettingAServiceStationTypeFromAPI),
    ("testGettingNearestStationsByParameters", testGettingNearestStationsByParameters),
    ("testDeletingStations", testDeletingStations),
    ("testServiceTypeCanBeUpdated", testServiceTypeCanBeUpdated)
  ]
}



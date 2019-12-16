@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class SensorTests: XCTestCase {
  let isEmptyPlace = true
  let sensorURL = "/api/sensors/"
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
  
  func testSensorsCanBeRetrievedFromAPI() throws {
    let sensor = try Sensor.create(isemptyPlace: isEmptyPlace, serviceStation: nil, on: conn)
    _ = try Sensor.create(on: conn)
    
    let sensors = try app.getResponse(to: sensorURL, decodeTo: [Sensor].self)
    
    XCTAssertEqual(sensors.count, 2)
    XCTAssertEqual(sensors[0].id, sensor.id)
  }
  
  func testSensorCanBeSavedWithAPI() throws {
    let serviceType = try App.ServiceType(typeName: "Car wash").save(on: conn).wait()
    let serviceStation = try ServiceStation(
      name: "Speedwash",
      description: "-----",
      latitude: 23.454,
      longtitude: 43.433,
      type: serviceType.id!).save(on: conn).wait()
    let sensor = Sensor(isEmptyPlace: isEmptyPlace, ownerId: serviceStation.id!)
    
    let recievedSensor = try app.getResponse(
      to: sensorURL,
      method: .POST,
      headers: ["Content-Type": "application/json"],
      data: sensor,
      decodeTo: Sensor.self)
    
    XCTAssertNotNil(recievedSensor.id)
    
    let sensors = try app.getResponse(to: sensorURL, decodeTo: [Sensor].self)
    
    XCTAssertEqual(sensors.count, 1)
    XCTAssertEqual(sensors[0].id, recievedSensor.id)
    XCTAssertEqual(sensors[0].ownerId, serviceStation.id)
  }
  
  func testSensorStateCanBeUpdated() throws {
    let serviceType = try App.ServiceType(typeName: "Car wash").save(on: conn).wait()
    let serviceStation = try ServiceStation(
      name: "Speedwash",
      description: "-----",
      latitude: 23.454,
      longtitude: 43.433,
      type: serviceType.id!).save(on: conn).wait()
    let sensor = try Sensor(isEmptyPlace: isEmptyPlace, ownerId: serviceStation.id!).save(on: conn).wait()
    
    let updatedSensor = try app.getResponse(
      to: "\(sensorURL)update/\(sensor.id!)?state=\(!isEmptyPlace)",
      method: .POST,
      headers: [:],
      decodeTo: Sensor.self)
    
    XCTAssertEqual(sensor.id, updatedSensor.id)
    XCTAssertEqual(sensor.isEmptyPlace, !updatedSensor.isEmptyPlace)
  }
  
  func testDeletingSensor() throws {
    let sensor = try Sensor.create(on: conn)
    var sensors = try app.getResponse(to: sensorURL, decodeTo: [Sensor].self)
    
    XCTAssertEqual(sensors.count, 1)
    
    _ = try app.sendRequest(to: "\(sensorURL)\(sensor.id!)", method: .DELETE)
    sensors = try app.getResponse(to: sensorURL, decodeTo: [Sensor].self)
    
    XCTAssertEqual(sensors.count, 0)
  }
  
  
  static let allTests = [
    ("testSensorsCanBeRetrievedFromAPI", testSensorsCanBeRetrievedFromAPI),
    ("testSensorCanBeSavedWithAPI", testSensorCanBeSavedWithAPI),
    ("testSensorStateCanBeUpdated", testSensorStateCanBeUpdated),
    ("testDeletingSensor", testDeletingSensor)
  ]
}


@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class RoadSensorTests: XCTestCase {
  let isOverlaped = false
  let amountOfStateChanges = 2
  let roadsSensorURL = "/api/road_sensors/"
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
  
  func testRoadSensorsCanBeRetrievedFromAPI() throws {
    let sensor = try RoadSensor.create(isOverlaped: isOverlaped,
                                       amountOfStateChanges: amountOfStateChanges,
                                       on: conn)
    _ = try RoadSensor.create(on: conn)
    
    let sensors = try app.getResponse(to: roadsSensorURL, decodeTo: [RoadSensor].self)
    
    XCTAssertEqual(sensors.count, 2)
    XCTAssertEqual(sensors[0].id, sensor.id)
    XCTAssertEqual(sensors[0].amountOfStateChanges, sensor.amountOfStateChanges)
    XCTAssertEqual(sensors[0].roadId, sensor.roadId)
  }
  
  func testSingleSensorCanBeRetrievedFromAPI() throws {
    let sensor = try RoadSensor.create(on: conn)
    let returnedSensor = try app.getResponse(to: "\(roadsSensorURL)\(sensor.id!)", decodeTo: RoadSensor.self)

    XCTAssertEqual(sensor.id, returnedSensor.id)
    XCTAssertEqual(sensor.amountOfStateChanges, returnedSensor.amountOfStateChanges)
    XCTAssertEqual(sensor.isOverlaped, returnedSensor.isOverlaped)
    XCTAssertEqual(sensor.roadId, returnedSensor.roadId)
  }
  
  func testRoadSensorCanBeSavedWithAPI() throws {
    let road = try Road.create(on: conn)
    let roadSensor = try RoadSensor.create(isOverlaped: isOverlaped,
                                       road: road,
                                       amountOfStateChanges: amountOfStateChanges,
                                       on: conn)
    
    let recievedSensor = try app.getResponse(
      to: roadsSensorURL,
      method: .POST,
      headers: ["Content-Type": "application/json"],
      data: roadSensor,
      decodeTo: RoadSensor.self)
    
    XCTAssertNotNil(recievedSensor.id)
    
    let sensors = try app.getResponse(to: roadsSensorURL, decodeTo: [RoadSensor].self)
    
    XCTAssertEqual(sensors.count, 1)
    XCTAssertEqual(sensors[0].id, recievedSensor.id)
    XCTAssertEqual(sensors[0].isOverlaped, recievedSensor.isOverlaped)
    XCTAssertEqual(sensors[0].amountOfStateChanges, recievedSensor.amountOfStateChanges)
    XCTAssertEqual(sensors[0].roadId, road.id)
  }
  
  func testRoadSensorAmountCanBeReseted() throws {
    let road = try Road.create(on: conn)
    let roadSensor = try RoadSensor.create(
      isOverlaped: true,
      road: road,
      amountOfStateChanges: 5,
      on: conn)
    
    let updatedSensor = try app.getResponse(
      to: "\(roadsSensorURL)reset/\(roadSensor.id!)",
      method: .POST,
      headers: [:],
      decodeTo: RoadSensor.self)
    
    XCTAssertEqual(roadSensor.id, updatedSensor.id)
    XCTAssertEqual(roadSensor.isOverlaped, updatedSensor.isOverlaped)
    XCTAssertEqual(roadSensor.roadId, updatedSensor.roadId)
    XCTAssertEqual(updatedSensor.amountOfStateChanges, 0)
  }
  
  func testRoadSensorStateCanBeChnaged() throws {
    let road = try Road.create(on: conn)
    let roadSensor = try RoadSensor.create(
      isOverlaped: true,
      road: road,
      amountOfStateChanges: 5,
      on: conn)
    
    let updatedSensor = try app.getResponse(
      to: "\(roadsSensorURL)update/\(roadSensor.id!)?state=\(!roadSensor.isOverlaped)",
      method: .POST,
      headers: [:],
      decodeTo: RoadSensor.self)
    
    XCTAssertEqual(roadSensor.id, updatedSensor.id)
    XCTAssertEqual(roadSensor.isOverlaped, !updatedSensor.isOverlaped)
    XCTAssertEqual(roadSensor.amountOfStateChanges + 1, updatedSensor.amountOfStateChanges)
    XCTAssertEqual(roadSensor.roadId, updatedSensor.roadId)
  }
  
  func testDeletingSensor() throws {
    let sensor = try RoadSensor.create(on: conn)
    var sensors = try app.getResponse(to: roadsSensorURL, decodeTo: [RoadSensor].self)
    
    XCTAssertEqual(sensors.count, 1)
    
    _ = try app.sendRequest(to: "\(roadsSensorURL)\(sensor.id!)", method: .DELETE)
    sensors = try app.getResponse(to: roadsSensorURL, decodeTo: [RoadSensor].self)
    
    XCTAssertEqual(sensors.count, 0)
  }
  
  
  static let allTests = [
    ("testRoadSensorsCanBeRetrievedFromAPI", testRoadSensorsCanBeRetrievedFromAPI),
    ("testSingleSensorCanBeRetrievedFromAPI", testSingleSensorCanBeRetrievedFromAPI),
    ("testRoadSensorCanBeSavedWithAPI", testRoadSensorCanBeSavedWithAPI),
    ("testRoadSensorAmountCanBeReseted", testRoadSensorAmountCanBeReseted),
    ("testRoadSensorStateCanBeChnaged", testRoadSensorStateCanBeChnaged),
    ("testDeletingSensor", testDeletingSensor)
  ]
}



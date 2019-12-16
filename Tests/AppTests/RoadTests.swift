@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class RoadTests: XCTestCase {
  let address = "Gagarina ave."
  let roadDescription = "------"
  let maxAllowedSpeed = 60
  let amountOfLines = 3
  let length = 66.4
  let bandwidth = 45
  let roadURL = "/api/roads/"
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
  
  func testRoadsCanBeRetrievedFromAPI() throws {
    let road = try Road.create(on: conn)
    _ = try Road.create(
      addres: address,
      description: roadDescription,
      maxAllowedSpeed: maxAllowedSpeed,
      amountOfLines: amountOfLines,
      length: length,
      bandwidth: bandwidth,
      on: conn)

    let roads = try app.getResponse(to: roadURL, decodeTo: [Road].self)

    XCTAssertEqual(roads.count, 2)
    XCTAssertEqual(roads[0].id, road.id)
    XCTAssertEqual(roads[0].address, road.address)
    XCTAssertEqual(roads[0].description, road.description)
    XCTAssertEqual(roads[0].maxAllowedSpeed, road.maxAllowedSpeed)
    XCTAssertEqual(roads[0].amountOfLines, road.amountOfLines)
    XCTAssertEqual(roads[0].length, road.length)
    XCTAssertEqual(roads[0].bandwidth, road.bandwidth)
  }
  
  func testSingleRoadCanBeRetrievedFromAPI() throws {
    let road = try Road.create(on: conn)
    let returnedRoad = try app.getResponse(to: "\(roadURL)\(road.id!)", decodeTo: Road.self)

    XCTAssertEqual(road.id, returnedRoad.id)
    XCTAssertEqual(road.address, returnedRoad.address)
    XCTAssertEqual(road.description, returnedRoad.description)
    XCTAssertEqual(road.maxAllowedSpeed, returnedRoad.maxAllowedSpeed)
    XCTAssertEqual(road.amountOfLines, returnedRoad.amountOfLines)
    XCTAssertEqual(road.length, returnedRoad.length)
    XCTAssertEqual(road.bandwidth, returnedRoad.bandwidth)
  }
  
   func testRoadCanBeSavedWithAPI() throws {
    let road = try Road.create(on: conn)

    let recievedRoad = try app.getResponse(
      to: roadURL,
      method: .POST,
      headers: ["Content-Type": "application/json"],
      data: road,
      decodeTo: Road.self)

    XCTAssertEqual(recievedRoad.address, road.address)
    XCTAssertNotNil(recievedRoad.id)

    let roads = try app.getResponse(to: roadURL, decodeTo: [Road].self)

    XCTAssertEqual(roads.count, 1)
    XCTAssertEqual(roads[0].id, road.id)
    XCTAssertEqual(roads[0].address, road.address)
    XCTAssertEqual(roads[0].description, road.description)
    XCTAssertEqual(roads[0].maxAllowedSpeed, road.maxAllowedSpeed)
    XCTAssertEqual(roads[0].amountOfLines, road.amountOfLines)
    XCTAssertEqual(roads[0].length, road.length)
    XCTAssertEqual(roads[0].bandwidth, road.bandwidth)
  }

  func testGettingARoadSensorsFromAPI() throws {
    let road = try Road.create(on: conn)

    let sensorState = false
    let amountOfStateChanges = 0

    let roadSensor = try RoadSensor.create(
      isOverlaped: sensorState,
      road: road,
      amountOfStateChanges: amountOfStateChanges,
      on: conn)

    _ = try RoadSensor.create(
      isOverlaped: sensorState,
      road: road,
      amountOfStateChanges: amountOfStateChanges,
      on: conn)

    let sensors = try app.getResponse(to: "\(roadURL)\(road.id!)/sensors", decodeTo: [RoadSensor].self)

    XCTAssertEqual(sensors.count, 2)
    XCTAssertEqual(sensors[0].id, roadSensor.id)
    XCTAssertEqual(sensors[0].isOverlaped, roadSensor.isOverlaped)
    XCTAssertEqual(sensors[0].amountOfStateChanges, roadSensor.amountOfStateChanges)
    XCTAssertEqual(sensors[0].roadId, road.id)
  }

  func testDeletingRoad() throws {
    let road = try Road.create(on: conn)
    var roads = try app.getResponse(to: roadURL, decodeTo: [Road].self)

    XCTAssertEqual(roads.count, 1)

    _ = try app.sendRequest(to: "\(roadURL)\(road.id!)", method: .DELETE)
    roads = try app.getResponse(to: roadURL, decodeTo: [Road].self)

    XCTAssertEqual(roads.count, 0)
  }

  func testRoadCanBeUpdated() throws {
    let road = try Road.create(on: conn)
    _ = try app.getResponse(
      to: "\(roadURL)\(road.id!)",
      method: .PUT,
      headers: ["Content-Type": "application/json"],
      data: Road(address: address,
                 description: roadDescription,
                 maxAllowedSpeed: maxAllowedSpeed,
                 amountOfLines: amountOfLines,
                 length: length,
                 bandwidth: bandwidth),
      decodeTo: Road.self)

    let returnedRoad = try app.getResponse(to: "\(roadURL)\(road.id!)", decodeTo: Road.self)

    XCTAssertEqual(returnedRoad.id, road.id)
    XCTAssertEqual(returnedRoad.address, address)
    XCTAssertEqual(returnedRoad.description, roadDescription)
    XCTAssertEqual(returnedRoad.maxAllowedSpeed, maxAllowedSpeed)
    XCTAssertEqual(returnedRoad.amountOfLines, amountOfLines)
    XCTAssertEqual(returnedRoad.length, length)
    XCTAssertEqual(returnedRoad.bandwidth, bandwidth)
  }

  static let allTests = [
    ("testRoadsCanBeRetrievedFromAPI", testRoadsCanBeRetrievedFromAPI),
    ("testSingleRoadCanBeRetrievedFromAPI", testSingleRoadCanBeRetrievedFromAPI),
    ("testRoadCanBeSavedWithAPI", testRoadCanBeSavedWithAPI),
    ("testGettingARoadSensorsFromAPI", testGettingARoadSensorsFromAPI),
    ("testDeletingRoad", testDeletingRoad),
    ("testRoadCanBeUpdated", testRoadCanBeUpdated)
  ]
}



@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class ServiceTypeTests: XCTestCase {
  let typeName = "Car wash"
  let serviceTypeURL = "/api/service_types/"
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
  
  func testServiceTypesCanBeRetrievedFromAPI() throws {
    let serviceType = try App.ServiceType.create(typeName: typeName, on: conn)
    _ = try App.ServiceType.create(on: conn)
    
    let serviceTypes = try app.getResponse(to: serviceTypeURL, decodeTo: [App.ServiceType].self)
    
    XCTAssertEqual(serviceTypes.count, 2)
    XCTAssertEqual(serviceTypes[0].typeName, typeName)
    XCTAssertEqual(serviceTypes[0].id, serviceType.id)
  }
  
  func testSingleServiceTypeCanBeRetrievedFromAPI() throws {
    let serviceType = try App.ServiceType.create(typeName: typeName, on: conn)
    let returnedType = try app.getResponse(to: "\(serviceTypeURL)\(serviceType.id!)", decodeTo: App.ServiceType.self)
    
    XCTAssertEqual(serviceType.id, returnedType.id)
    XCTAssertEqual(serviceType.typeName, returnedType.typeName)
  }
  
  func testServiceTypeCanBeSavedWithAPI() throws {
    let serviceType = App.ServiceType(typeName: typeName)
    
    let recievedServiceType = try app.getResponse(
      to: serviceTypeURL,
      method: .POST,
      headers: ["Content-Type": "application/json"],
      data: serviceType,
      decodeTo: App.ServiceType.self)
    
    XCTAssertEqual(recievedServiceType.typeName, typeName)
    XCTAssertNotNil(recievedServiceType.id)
    
    let serviceTypes = try app.getResponse(to: serviceTypeURL, decodeTo: [App.ServiceType].self)
    
    XCTAssertEqual(serviceTypes.count, 1)
    XCTAssertEqual(serviceTypes[0].typeName, typeName)
    XCTAssertEqual(serviceTypes[0].id, recievedServiceType.id)
  }
  
  func testGettingAServiceTypeServiceStationsFromAPI() throws {
    let serviceType = try App.ServiceType.create(on: conn)
    
    let serviceStationName = "Autofix"
    let serviceStationDescription = "---------"
    let latitude: Double = 34.4657
    let longtitude: Double = 48.3578
    
    let serviceStation = try ServiceStation.create(
      name: serviceStationName,
      description: serviceStationDescription,
      latitude: latitude,
      longtitude: longtitude,
      serviceType: serviceType,
      on: conn)
    
    _ = try ServiceStation.create(
      name: "Speed Fix",
      description: "------|------",
      latitude: 34.5757,
      longtitude: 59.3838,
      serviceType: serviceType,
      on: conn)
    
    guard let serviceTypeId = serviceType.id else { return }
    let serviceStations = try app.getResponse(to: "\(serviceTypeURL)\(serviceTypeId)/services", decodeTo: [ServiceStation].self)
    
    XCTAssertEqual(serviceStations.count, 2)
    XCTAssertEqual(serviceStations[0].id, serviceStation.id)
    XCTAssertEqual(serviceStations[0].name, serviceStation.name)
    XCTAssertEqual(serviceStations[0].description, serviceStation.description)
    XCTAssertEqual(serviceStations[0].latitude, serviceStation.latitude)
    XCTAssertEqual(serviceStations[0].longtitude, serviceStation.longtitude)
  }
  
  func testDeletingServiceType() throws {
    let serviceType = try App.ServiceType.create(on: conn)
    var serviceTypes = try app.getResponse(to: serviceTypeURL, decodeTo: [App.ServiceType].self)

    XCTAssertEqual(serviceTypes.count, 1)

    _ = try app.sendRequest(to: "\(serviceTypeURL)\(serviceType.id!)", method: .DELETE)
    serviceTypes = try app.getResponse(to: serviceTypeURL, decodeTo: [App.ServiceType].self)

    XCTAssertEqual(serviceTypes.count, 0)
  }
  
  func testServiceTypeCanBeUpdated() throws {
    let serviceType = try App.ServiceType(typeName: typeName).save(on: conn).wait()
    let newTypeName = "Service station"
    _ = try app.getResponse(
      to: "\(serviceTypeURL)\(serviceType.id!)",
      method: .PUT,
      headers: ["Content-Type": "application/json"],
      data: App.ServiceType(typeName: newTypeName),
      decodeTo: App.ServiceType.self)
    
    let returnedType = try app.getResponse(to: "\(serviceTypeURL)\(serviceType.id!)", decodeTo: App.ServiceType.self)
    
    XCTAssertEqual(returnedType.id, serviceType.id)
    XCTAssertEqual(returnedType.typeName, newTypeName)
  }
  
  
  static let allTests = [
    ("testServiceTypesCanBeRetrievedFromAPI", testServiceTypesCanBeRetrievedFromAPI),
    ("testServiceTypeCanBeSavedWithAPI", testServiceTypeCanBeSavedWithAPI),
    ("testGettingAServiceTypeServiceStationsFromAPI", testGettingAServiceTypeServiceStationsFromAPI),
    ("testDeletingServiceType", testDeletingServiceType),
    ("testServiceTypeCanBeUpdated", testServiceTypeCanBeUpdated),
    ("testSingleServiceTypeCanBeRetrievedFromAPI", testSingleServiceTypeCanBeRetrievedFromAPI)
  ]
}

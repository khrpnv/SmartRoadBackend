import XCTest
// 1
@testable import AppTests
// 2
XCTMain([
  testCase(SensorTests.allTests),
  testCase(ServiceTypeTests.allTests),
  testCase(ServiceStationTests.allTests),
  testCase(RoadTests.allTests),
  testCase(RoadSensorTests.allTests)
])

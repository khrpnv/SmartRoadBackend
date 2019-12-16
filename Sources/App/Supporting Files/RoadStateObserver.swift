//
//  StateChangesCalculator.swift
//  App
//
//  Created by Illia Khrypunov on 11/24/19.
//

import Foundation

struct RoadStateObserver {
  public static func roadState(sensors: [RoadSensor], availability: Int) -> String {
    var totalAmount = 0
    for sensor in sensors {
      totalAmount += sensor.amountOfStateChanges
    }
    return totalAmount < availability ? "available" : "jam"
  }
}

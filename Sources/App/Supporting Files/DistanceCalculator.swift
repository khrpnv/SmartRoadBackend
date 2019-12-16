//
//  DistanceCalculator.swift
//  App
//
//  Created by Illia Khrypunov on 11/23/19.
//

import Foundation
import FluentPostgreSQL

struct DistanceCalculator {
  static func countDistance(startLat: Double, startLong: Double, endLat: Double, endLong: Double) -> Double {
    let earthRadius: Double = 6372795
    
    let lat1 = startLat * .pi / 180
    let long1 = startLong * .pi / 180
    let lat2 = endLat * .pi / 180
    let long2 = endLong * .pi / 180
    
    let cos1 = cos(lat1)
    let cos2 = cos(lat2)
    let sin1 = sin(lat1)
    let sin2 = sin(lat2)
    
    let delta = long2 - long1
    let cDelta = cos(delta)
    let sDelta = sin(delta)
    
    let y = sqrt(pow(cos2 * sDelta, 2) + pow(cos1 * sin2 - sin1 * cos2 * cDelta, 2))
    let x = sin1 * sin2 + cos1 * cos2 * cDelta
    
    let ad = atan2(y, x)
    let distance = ad * earthRadius
    
    return distance / 1000
  }
}

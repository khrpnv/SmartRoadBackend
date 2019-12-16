//
//  AuthorizationManager.swift
//  App
//
//  Created by Illia Khrypunov on 12/15/19.
//

import Foundation
import Vapor

final class AuthorizationManager {
  public static let instance = AuthorizationManager()
  
  private var isAuthorized: Bool = false
  
  public func setAuthorizeValue(value: Bool) {
    isAuthorized = value
  }
  
  public func checkAuthorization() throws {
    if !isAuthorized {
      throw Abort(.badRequest, reason: "user is not authorized" , identifier: nil)
    }
  }
  
  public func isAlreadyAuthorized() throws {
    if isAuthorized {
      throw Abort(.badRequest, reason: "user is already authorized" , identifier: nil)
    }
  }
}

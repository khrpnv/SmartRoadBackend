import Vapor
import Authentication
import Crypto

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  router.get { req in
    return "It works!"
  }
  
  let sensorsController = SensorsController()
  try router.register(collection: sensorsController)
  
  let serviceStationsController = ServiceStationsController()
  try router.register(collection: serviceStationsController)
  
  let serviceTypesController = ServiceTypesController()
  try router.register(collection: serviceTypesController)
  
  let roadsController = RoadsController()
  try router.register(collection: roadsController)
  
  let roadSensorsController = RoadSensorsController()
  try router.register(collection: roadSensorsController)
  
  let usersController = UsersController()
  try router.register(collection: usersController)
}

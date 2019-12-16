import Vapor
import Fluent

struct ServiceTypesController: RouteCollection {
  func boot(router: Router) throws {
    let serviceTypesRoutes = router.grouped("api", "service_types")
    serviceTypesRoutes.get(use: getAllHandler)
    serviceTypesRoutes.post(use: createHandler)
    serviceTypesRoutes.get(ServiceType.parameter, "services", use: getServicesByType)
    serviceTypesRoutes.get(ServiceType.parameter, use: getServiceTypeById)
    serviceTypesRoutes.put(ServiceType.parameter, use: updateHandler)
    serviceTypesRoutes.delete(ServiceType.parameter, use: deleteHanlder)
  }
  
  // MARK: - Create
  func createHandler(_ request: Request) throws -> Future<ServiceType> {
    return try request
      .content
      .decode(ServiceType.self)
      .flatMap(to: ServiceType.self, { serviceType in
        serviceType.save(on: request)
      })
  }
  
  // MARK: - Read
  func getAllHandler(_ request: Request) throws -> Future<[ServiceType]> {
    return ServiceType.query(on: request).all()
  }
  
  func getServicesByType(_ request: Request) throws -> Future<[ServiceStation]> {
    return try request.parameters.next(ServiceType.self)
    .flatMap(to: [ServiceStation].self, { serviceType in
      return try serviceType.facilities.query(on: request).all()
    })
  }
  
  func getServiceTypeById(_ request: Request) throws -> Future<ServiceType> {
    return try request.parameters.next(ServiceType.self)
  }
  
  // MARK: - Update
  func updateHandler(_ request: Request) throws -> Future<ServiceType> {
    return try flatMap(
      to: ServiceType.self,
      request.parameters.next(ServiceType.self),
      request.content.decode(ServiceType.self),
      { type, updatedType in
        type.typeName = updatedType.typeName
        return type.save(on: request)
    })
  }
  
  // MARK: - Delete
  func deleteHanlder(_ request: Request) throws -> Future<HTTPStatus> {
    return try request
      .parameters
      .next(ServiceType.self)
      .delete(on: request)
      .transform(to: .noContent)
  }
}

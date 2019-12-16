// swift-tools-version:4.0
import PackageDescription

let package = Package(
  name: "Backend",
  products: [
    .library(name: "Backend", targets: ["App"]),
  ],
  dependencies: [
    // A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
    .package(url: "https://github.com/vapor/crypto.git", from: "3.0.0"),
    // Swift ORM (queries, models, relations, etc) built on PostgreSQL.
    .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
    // Authentication
    .package(url: "https://github.com/vapor/auth.git", from: "2.0.0")
  ],
  targets: [
    .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "Authentication"]),
    .target(name: "Run", dependencies: ["App"]),
    .testTarget(name: "AppTests", dependencies: ["App"])
  ]
)

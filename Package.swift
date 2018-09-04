// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "kazaki",
    dependencies: [
        // 💧 Пакет Vapor для создания web-сервера на Swift.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (запросы, модели, связи, прочее) на основе SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        
        // 🍃 Выразительный, производительный и расширяемый язык шаблонов для Swift.
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        
        // 👤 Пакет авторизации и аутинфикации для Fluent.
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
    ],
    targets: [
        .target(name: "App", dependencies: [ "Vapor", "Leaf", "FluentSQLite", "Authentication"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)


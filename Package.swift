// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "kazaki",
    dependencies: [
        // 💧 Пакет Vapor для создания web-сервера на Swift.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (запросы, модели, связи, прочее) на основе SQLite 3.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        
        // 🍃 Выразительный, производительный и расширяемый язык шаблонов для Swift.
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        
        // 👤 Пакет авторизации и аутинфикации для Fluent.
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        
        // Пакет для защиты сессий CSRF
        .package(url: "https://github.com/vapor-community/CSRF.git", from: "2.0.0"),
        
        // Пакет для блокировки запросов на основе заголовков origin и referer
        .package(url: "https://github.com/vapor-community/moat.git", from: "0.0.6"),
        
        // Защита по Content-Security-Policy, X-XSS-Protection, X-Frame-Options and X-Content-Type-Options
        .package(url: "https://github.com/brokenhandsio/VaporSecurityHeaders.git", from: "2.0.0"),
        
        // Пакет который обеспечивает отправку писем
        .package(url: "https://github.com/IBM-Swift/Swift-SMTP", .upToNextMinor(from: "5.1.0"))
    ],
    targets: [
        .target(name: "App", dependencies: [ "Vapor",
                                             "Leaf",
                                             "FluentPostgreSQL",
                                             "Authentication",
                                             "CSRF",
                                             "Moat",
                                             "VaporSecurityHeaders",
                                             "SwiftSMTP"
											 ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)


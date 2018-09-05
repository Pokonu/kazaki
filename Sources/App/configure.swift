import Vapor
import Leaf
import FluentPostgreSQL
import Authentication

let SQL_HOST: String = "localhost"
let SQL_PORT:Int = 5432
let SQL_DATABASE: String? = "main"
let SQL_USERNAME: String = "veresk"
let SQL_PASSWORD: String? = "UyK-2Dr-SQL-171"

/// Вызывается перед иницилизацией основного приложения app.swift.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    
    /// Регистрация менеджера шаблонов Leaf
    try services.register(LeafProvider())
    try services.register(AuthenticationProvider())
    
    /// Решистрация менеджера баз данных
    /// try services.register(FluentPostgreSQLProvider())

    /// Регистрация путей при загрузки приложения в браузере
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Регистрация "прослойки"
    var middlewares = MiddlewareConfig() // создаем пустую конфигурацию (_empty_) прослойки
    middlewares.use(SessionsMiddleware.self) // Разрешаем использование сессий.
    middlewares.use(FileMiddleware.self) // Обслуживаем файлы в папке `Public/`
    middlewares.use(ErrorMiddleware.self) // Ловим ошибки и преобразования в HTTP ответах
    services.register(middlewares)

    // Конфигурируем базу данных PostgreSQL
    let postgresql = PostgreSQLDatabase(config: PostgreSQLDatabaseConfig(hostname: SQL_HOST, port: SQL_PORT, username: SQL_USERNAME, database: SQL_DATABASE!, password: SQL_PASSWORD!))

    /// Регистрируем сервис для обсулживания сконфигурированной БД SQLite.
    var databases = DatabasesConfig()
    databases.enableLogging(on: .psql)
    databases.add(database: postgresql, as: .psql)
    services.register(databases)

    /// Кнфигурируем миграции
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: UserToken.self, database: .psql)
    migrations.add(model: Todo.self, database: .psql)
    services.register(migrations)

    /// Используем Leaf для прорисовки шаблонов web страниц
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    
}

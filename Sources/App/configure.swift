import Vapor
import Leaf
import FluentPostgreSQL
import Authentication

// Данные БД PostgreSQL для текущего проекта
// ПОМНИ, что перед началом запуска проекта
// необходимо установить на сервер пакет postgresql
// запустить сервер psql и создать пользователя БД
// с именем ниже и БД с именем ниже
//
// psql -U postgres -d postgres -W
// psql> create role veresk;
// psql> create database test owner veresk;
//
struct SQLParameters {
    let host: String = "localhost"
    let port:Int = 5432
    let database: String = "test"
    let username: String = "veresk"
    let password: String = "Test123"
}
let db = SQLParameters()

/// Вызывается перед иницилизацией основного приложения app.swift.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    
    /// Регистрация менеджера шаблонов Leaf
    try services.register(LeafProvider())
    try services.register(AuthenticationProvider())
    
    /// Регистрация менеджера баз данных
    //try services.register(FluentPostgreSQLProvider())

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
    var databases = DatabasesConfig()
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: db.host, port: db.port, username: db.username, database: db.database, password: db.password)
    let database = PostgreSQLDatabase(config: databaseConfig)
    
    /// Регистрируем сервис для обслуживания сконфигурированной БД SQLite.
    databases.enableLogging(on: .psql)
    databases.add(database: database, as: .psql)
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

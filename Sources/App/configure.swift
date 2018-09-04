import FluentSQLite
import Vapor

/// Вызывается перед иницилизацией основного приложения app.swift.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Решистрация менеджера баз данных
    try services.register(FluentSQLiteProvider())

    /// Регистрация путей при загрузки приложения в браузере
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Регистрация "прослойки"
    var middlewares = MiddlewareConfig() // создаем пустую конфигурацию (_empty_) прослойки
    /// middlewares.use(FileMiddleware.self) // Обслуживаем файлы в папке `Public/`
    middlewares.use(ErrorMiddleware.self) // Ловим ошибки и преобразования в HTTP ответах
    services.register(middlewares)

    // Конфигурируем базу данных SQLite
    let sqlite = try SQLiteDatabase(storage: .memory)

    /// Регистрируем сервис для обсулживания сконфигурированной БД SQLite.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    /// Кнфигурируем миграции
    var migrations = MigrationConfig()
    migrations.add(model: Todo.self, database: .sqlite)
    services.register(migrations)

}

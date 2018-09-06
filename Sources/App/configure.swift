import Vapor
import Leaf
import FluentPostgreSQL
import Authentication

// Данные БД PostgreSQL для текущего проекта
// ПОМНИ, что перед началом запуска проекта
// необходимо установить на сервер пакет postgresql
// запустить сервер psql и далее:
//
// psql -U postgres -d postgres -h localhost -W
// psql> CREATE DATABASE test;
// psql> CREATE USER testuser WITH password 'Test123';
// psql> GRANT ALL privileges ON DATABASE test TO testuser;
//
// Пример:
// https://webhamster.ru/mytetrashare/index/mtb0/1422535055yyw3jmui2c
//
struct SQLParameters {
    let host: String = "localhost"
    let port:Int = 5432
    let database: String = "test"
    let username: String = "testuser"
    let password: String = ""
}
let db = SQLParameters()

/// Вызывается перед иницилизацией основного приложения app.swift.
public func configure(_ config: inout Config,
                      _ env: inout Environment,
                      _ services: inout Services) throws {
    
    /// Регистрация обработчика HTML шаблонов
    try services.register(LeafProvider())
    /// Регистрация обработчика аунтификациионных запросов
    try services.register(AuthenticationProvider())
    
    /// Регистрация маршрутов при загрузки приложения в браузере
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Регистрируем конфигурацию папок проекта
    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)
    
    /// Регистрация "прослойки"
    var middlewares = MiddlewareConfig() // создаем пустую конфигурацию (_empty_) прослойки
    middlewares.use(SessionsMiddleware.self) // Разрешаем использование сессий.
    middlewares.use(FileMiddleware.self) // Обслуживаем файлы в папке `Public/`
    middlewares.use(ErrorMiddleware.self) // Ловим ошибки и преобразования в HTTP ответах
    services.register(middlewares)

    /// Регистрация обработчика баз данных
    try services.register(FluentPostgreSQLProvider())

    /// Конфигурируем базу данных PostgreSQL в ручном режиме
    /// Т.е. задаем ей начальные входные параметры для открытия
    var databases = DatabasesConfig()
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: db.host, port: db.port, username: db.username, database: db.database, password: nil)
    
    /// Регистрируем обработчик запросов для обслуживания БД PostgreSQL.
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.enableLogging(on: .psql)                  // Подключаем журналирование
    databases.add(database: database, as: .psql)        // Добавляем БД к списку рабоичх БД
    services.register(databases)                        // Регистрируем рабочие БД
    
    /// Кнфигурируем миграции созданных моделей (в папке Models)
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)       // Пользователи
    migrations.add(model: UserToken.self, database: .psql)  // Токены для пользователей
    migrations.add(model: Todo.self, database: .psql)       // Заметки пользователя
    services.register(migrations)

    /// Используем Leaf для прорисовки шаблонов web страниц
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    
}

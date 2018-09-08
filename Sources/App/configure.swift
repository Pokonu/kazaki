import Vapor
import Leaf
import FluentPostgreSQL
import Authentication
import CSRF
import Moat
import VaporSecurityHeaders
import SwiftSMTP

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
    let password: String? = nil
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
    
    // Конфигуратор защитного механизма сессий - CSRF
    let CSRFConfig = CSRF()
    services.register(CSRFConfig)
    
    // Ставим защитную прослойку Moat для HTML страниц
    var tags = LeafTagConfig.default()
    tags.use(ProfanityTag(), as: "clean")
    tags.use(SrcTag(), as: "src")
    tags.use(SrcTag(), as: "href")
    tags.use(HtmlTag(), as: "html")
    tags.use(ShrugTag(), as: "shrug")
    services.register(tags)
    
    // Защита заголовков HEAD: Content-Security-Policy,
    // X-XSS-Protection, X-Frame-Options and X-Content-Type-Options.
    let securityHeadersFactory = SecurityHeadersFactory()
    services.register(securityHeadersFactory.build())
    
    // Конфигурирование и регистрация "слоев-послоек"
    configureMiddlewares(&services)
    
    /// Конфигурирование и регистрация обработчика баз данных
    try services.register(FluentPostgreSQLProvider())
    configureDatabases(&services)

    // Конфигурирование и регистрация обработчика отправки email
    //configureEmailSending(apikey: API_KEY, services: &services)
    
    /// Используем Leaf для прорисовки шаблонов web страниц
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)

}


// Конфигурирование и регистрация "слоев-послоек"
func configureMiddlewares(_ services: inout Services) {
    
    /// Регистрация "прослойки"
    var middlewares = MiddlewareConfig() // создаем пустую конфигурацию (_empty_) прослойки
    // Ставим Moat - защиту запросов на основе заголовков origin и referer
    let originProtection = OriginCheckMiddleware(origin: db.host,
                                                 referer: "\(db.host)/",
                                                 failopen: true,
                                                 reason: "Проверка подлиности запроса завершилась неудачей.")
    middlewares.use(originProtection)
    middlewares.use(SessionsMiddleware.self) // Разрешаем использование сессий.
    middlewares.use(FileMiddleware.self) // Обслуживаем файлы в папке `Public/`
    middlewares.use(CSRF.self)            // Прослойка защитного механизма сессий - CSRF
    
    // Подключаем модуль взаимодействия (CORS) с JavaScript на стороне клиента
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    middlewares.use(corsMiddleware)         // Ловим ошибки и преобразования в HTTP ответах
    middlewares.use(ErrorMiddleware.self)
    
    // Защита заголовков HEAD: Content-Security-Policy,
    // X-XSS-Protection, X-Frame-Options and X-Content-Type-Options.
    // Для управление в ручном режиме описано по ссылке ниже
    // https://github.com/brokenhandsio/VaporSecurityHeaders
    // Она должна регистрироваться в middlewares в последнюю очередь
    middlewares.use(SecurityHeaders.self)
    
    services.register(middlewares)
}

// Конфигурирование и регистрация обработчика баз данных
func configureDatabases(_ services: inout Services) {
    /// Конфигурируем базу данных PostgreSQL в ручном режиме
    /// Т.е. задаем ей начальные входные параметры для открытия
    var databases = DatabasesConfig()
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: db.host, port: db.port, username: db.username, database: db.database, password: db.password)
    
    /// Регистрируем обработчик запросов для обслуживания БД PostgreSQL.
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.enableLogging(on: .psql)                  // Подключаем журналирование
    databases.add(database: database, as: .psql)        // Добавляем БД к списку рабоичх БД
    
    /// Кнфигурируем миграции созданных моделей (в папке Models)
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)       // Пользователи
    migrations.add(model: UserToken.self, database: .psql)  // Токены для пользователей
    migrations.add(model: Todo.self, database: .psql)       // Заметки пользователя
    
    services.register(migrations)
    services.register(databases)                       // Регистрируем рабочие БД

}



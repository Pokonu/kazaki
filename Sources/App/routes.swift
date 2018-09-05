import Vapor
import Crypto

/// Здесь регистрируем задействуваемые в приложении пути.
public func routes(_ router: Router) throws {
 
    // отражет индексную страницу в корне
    router.get { req in
        return try req.view().render("welcome")
    }
    // Основной пример "Hello, world!"
    router.get("hello") { req in
        return "Hello, world!"
    }
    
   
    // Скажем hello при запросе '/hello/Greg'
    router.get("hello", String.parameter) { req -> Future<View> in
        return try req.view().render("hello", [
            "name": req.parameters.next(String.self)
            ])
    }
    
    
    router.get("info") { req -> String in
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        struct DataPrint: Content {
            var place: String
            var framework: String
            var time: String
        }
        let date = Date()
        let calendar = Calendar.current
        
        let hours = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        let time = "\(hours):\(minutes):\(seconds)"
        let jsonData = try encoder.encode(DataPrint(place: "Дом", framework: "Vapor", time: time))
        
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }

    struct PostgreSQLVersion: Codable {
        let version: String
    }
    
    router.get("sql") { req in
        return req.withPooledConnection(to: .psql) { conn in
            return conn.raw("SELECT version();")
                .all(decoding: PostgreSQLVersion.self)
            }.map { rows in
                return rows[0].version
        }
    }
    
    // Объявляем маршрут POST
    let userController = UserController()
    router.post("users", use: userController.create)
    
    // Основа защиты авторизации пользовательских маршрутов
    let basic = router.grouped(User.basicAuthMiddleware(using: BCryptDigest()))
    basic.post("login", use: userController.login)
    

    
    // Пример конфигурации контроллера для трех разных запросов
    // Предьявляем токен для защащенных маршрутов
    let bearer = router.grouped(User.tokenAuthMiddleware())
    let todoController = TodoController()
    bearer.get("todos", use: todoController.index)
    bearer.post("todos", use: todoController.create)
    bearer.delete("todos", Todo.parameter, use: todoController.delete)
    
    
    
}


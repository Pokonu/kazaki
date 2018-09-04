import Vapor
import Crypto

/// Здесь регистрируем задействуваемые в приложении пути.
public func routes(_ router: Router) throws {
    
    // Основной пример "Hello, world!"
    router.get("hello") { req in
        return "Hello, world!"
    }
    // отражет шаблон страницы welcome м надписью "It works"
    router.get { req in
        return try req.view().render("welcome")
    }
    
    // Скажем hello при запросе '/hello/Greg'
    router.get("hello", String.parameter) { req -> Future<View> in
        return try req.view().render("hello", [
            "name": req.parameters.next(String.self)
            ])
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


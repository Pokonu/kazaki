import Vapor

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
    
    // Пример конфигурации контроллера для трех разных запросов
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}


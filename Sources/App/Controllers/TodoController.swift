import Vapor
import FluentPostgreSQL

/// Простой контроллер todo-списка.
final class TodoController {
    /// Возвращает список все todos для определенного пользователя.
    func index(_ req: Request) throws -> Future<[Todo]> {
        // получаем id авторизированного пользователя.
        let user = try req.requireAuthenticated(User.self)
        
        // запррашиваем все todo's которые принадлежат пользователю
        return try Todo.query(on: req)
            .filter(\.userID == user.requireID()).all()
    }
    
    /// Создаем новую заметку todo для авторизированного пользователя.
    func create(_ req: Request) throws -> Future<Todo> {
        // получаем id пользователя, который уже авторизировался
        let user = try req.requireAuthenticated(User.self)
        
        // декодируем содержимое запроса
        return try req.content.decode(CreateTodoRequest.self).flatMap { todo in
            // сохраняем новоую заметку в БД
            return try Todo(title: todo.title, userID: user.requireID())
                .save(on: req)
        }
    }
    
    /// Удаляем существующую заметку todo для авторизированного пользователя.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        // получаем id авторизированного пользователя.
        let user = try req.requireAuthenticated(User.self)
        
        // декодируем содержимое запроса с параметром (todos/:id)
        return try req.parameters.next(Todo.self).flatMap { todo -> Future<Void> in
            // проверяем что удаляемые заметки принадлежат этому пользователю
            guard try todo.userID == user.requireID() else {
                throw Abort(.forbidden)
            }
            
            // удаляем модель
            return todo.delete(on: req)
            }.transform(to: .ok)
    }
}

// MARK: Content

/// Represents data required to create a new todo.
struct CreateTodoRequest: Content {
    /// Todo title.
    var title: String
}

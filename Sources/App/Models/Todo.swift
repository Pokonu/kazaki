import FluentPostgreSQL
import Vapor

/// Описание записи Todo списка.
final class Todo: PostgreSQLModel {
    /// The unique identifier for this `Todo`.
    var id: Int?

    /// Заголовок описывающий суть `Todo`.
    var title: String
    
    /// Ссылка на пользователя, которому принадлежит заметка TODO.
    var userID: User.ID
    
    /// Создание новой записи в `Todo`.
    init(id: Int? = nil, title: String, userID: User.ID) {
        self.id = id
        self.title = title
        self.userID = userID
    }
}

extension Todo {
    /// Описываем связь между пользователем и земеткой todo.
    var user: Parent<Todo, User> {
        return parent(\.userID)
    }
}

/// Разрешаем `Todo` принимать участие в динамической миграции.
extension Todo: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(Todo.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.title)
            builder.field(for: \.userID)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

/// Разрешаеем `Todo` коировку и декодирование из HTTP запросов.
extension Todo: Content { }

/// Разрешает `Todo` использовать динамические параметры в запросах .
extension Todo: Parameter { }

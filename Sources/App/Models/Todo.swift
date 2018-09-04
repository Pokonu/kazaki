import FluentSQLite
import Vapor

/// Описание записи Todo списка.
final class Todo: SQLiteModel {
    /// The unique identifier for this `Todo`.
    var id: Int?

    /// Заголовок описывающий суть `Todo`.
    var title: String

    /// Создание новой записи в `Todo`.
    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}

/// Разрешаем `Todo` принимать участие в динамической миграции.
extension Todo: Migration { }

/// Разрешаеем `Todo` коировку и декодирование из HTTP запросов.
extension Todo: Content { }

/// Разрешает `Todo` использовать динамические параметры в запросах .
extension Todo: Parameter { }

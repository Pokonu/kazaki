import Foundation
import Authentication
import FluentPostgreSQL
import Fluent
import Vapor

/// Описываем зарегистрированного пользователя, которому принадлежат заметки todo.
final class User: PostgreSQLModel {
    /// Уникальный идентификатор пользователя.
    /// Может быть 'nil', если пользователь еще не был сохранен.
    var id: Int?
    
    /// Полное имя пользователя.
    var name: String
    
    /// Адрес электронной почты пользователя.
    private(set) var email: String
    
    /// BCrypt хэш пароль пользователя..
    private(set) var passwordHash: String
    
    /// Создаем нового пользователя.
    init(id: Int? = nil, name: String, email: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
}

/// Позволяет пользователям проходить базовую аутификацию через ввод пароля.
extension User: PasswordAuthenticatable {
    /// Смотрите `PasswordAuthenticatable`.
    static var usernameKey: WritableKeyPath<User, String> {
        return \.email
    }
    
    /// Смотрите `PasswordAuthenticatable`.
    static var passwordKey: WritableKeyPath<User, String> {
        return \.passwordHash
    }
}

/// Позволяет пользователям проходить базовую аутификацию посредством предъявления токена.
extension User: TokenAuthenticatable {
    /// Смотрите `TokenAuthenticatable`.
    typealias TokenType = UserToken
}

///Позволяет осуществлять 'User' для плавной миграции.
extension User: Migration {
    /// Смотрите `Migration`.
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(User.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.name)
            builder.field(for: \.email)
            builder.field(for: \.passwordHash)
            builder.unique(on: \.email)
        }
    }
}

/// Позволяет "User" кодироваться и раскодироваться при помощи HTTP запросов.
extension User: Content { }

/// Позволяем `User` использовать в качестве динамического параметра в маршрутах.
extension User: Parameter { }

import Authentication
import Crypto
import FluentPostgreSQL
import Vapor

/// Описывает временный маркер проверки подлинности,
/// идентифицирующий зарегистрированного пользователя.
final class UserToken: PostgreSQLModel {
    /// Создает новый `UserToken` для данного пользователя.
    static func create(userID: User.ID) throws -> UserToken {
        // Генерирует случайные 128-битовые, base64-encoded строки.
        let string = try CryptoRandom().generateData(count: 16).base64EncodedString()
        // иницилизирует новый `UserToken` из этой строки.
        return .init(string: string, userID: userID)
    }
    
    /// Смотрите `Model`.
    static var deletedAtKey: TimestampKey? { return \.expiresAt }
    
    /// Уникальный пользовательский индификатор UserToken.
    var id: Int?
    
    /// Уникальная строка токена.
    var string: String
    
    /// Индификатор пользователя, которому принадлежит этот токен.
    var userID: User.ID
    
    /// Срок годности. Токен больше не будет действителен после этого момента.
    var expiresAt: Date?
    
    /// Создает новый `UserToken`.
    init(id: Int? = nil, string: String, userID: User.ID) {
        self.id = id
        self.string = string
        // установливает срок годности токена продолжительность 5 часов
        self.expiresAt = Date.init(timeInterval: 60 * 60 * 5, since: .init())
        self.userID = userID
    }
}

extension UserToken {
    /// Определяем связку пользователь - токен.
    var user: Parent<UserToken, User> {
        return parent(\.userID)
    }
}

/// Позволяет использовать эту модель в качестве маркера Authenticatable.
extension UserToken: Token {
    /// Смотрите `Token`.
    typealias UserType = User
    
    /// Смотрите `Token`.
    static var tokenKey: WritableKeyPath<UserToken, String> {
        return \.string
    }
    
    /// Смотрите `Token`.
    static var userIDKey: WritableKeyPath<UserToken, User.ID> {
        return \.userID
    }
}

/// Позволяет использовать 'User Token' для быстрой миграции.
extension UserToken: Migration {
    /// Смотрите `Migration`.
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(UserToken.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.string)
            builder.field(for: \.userID)
            builder.field(for: \.expiresAt)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

/// Разрешаем `UserToken` кодироваться и раскодироваться при помощи HTTP запросов.
extension UserToken: Content { }

/// Позволяем `UserToken` использовать в качестве динамического параметра в маршрутах.
extension UserToken: Parameter { }

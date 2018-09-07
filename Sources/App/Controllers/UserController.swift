import Crypto
import Vapor
import FluentPostgreSQL
import CSRF
import SwiftSMTP

let csrf = CSRF()


/// Создаем новых пользователей и решистрируем их.
final class UserController {
    /// Регистрируем пользователя и возвращаем токен для доступа к защищенным модулям проекта.
    func login(_ req: Request) throws -> Future<UserToken> {
        // аторизируем пользователя
        let user = try req.requireAuthenticated(User.self)
        
        // создаем новый токен для пользователя
        let token = try UserToken.create(userID: user.requireID())
        
        // сохраняем и возвращаем токен
        return token.save(on: req)
    }
    
    // Возвращает список всех пользователей в базе данных в виде JSON
    func userList(_ req: Request) throws -> Future<[User]>  {
        return User.query(on: req).all()
    }
    
    // Возвращает список всех пользователей в базе данных в виде HTML страницы
    func showUsersList(_ req: Request) throws -> Future<View> {
    //func showUsersList(_ req: Request) throws -> Response {
        let token = try csrf.createToken(from: req)
        let context = UsersContext(users: User.query(on: req).all(), csrf: token)
        
        return try req.view().render("users", context)
    }
    
    // Получаем конкретного пользователя
    // /users/<id>, например /users/2
    func getUserById(_ req: Request) throws -> Future<User>{
        let user = try req.parameters.next(User.self)
        return user
    }
    
    // создаем нового пользователя и записываем в БД через POST запрос
    // данные пользователя без хеширования пароля (чистый текст)
    /*
    func addUser(_ req: Request) throws -> Future<User>  {
        let user = try req.content.syncDecode(User.self)
        return user.save(on: req)
    }
     */
    
    //
    /// Регистрируем нового пользователя и записываем в БД через POST запрос
    /// данные пользователя передаюся с хешированием пароля (кодированный)
    ///
    func create(_ req: Request) throws -> Future<UserResponse> {
        // декодируем содержимое запроса
        return try req.content.decode(CreateUserRequest.self).flatMap { user -> Future<User> in
            // проверям пароли (основной и проверочный) на совпадение
            guard user.password == user.verifyPassword else {
                throw Abort(.badRequest, reason: "Пароли должны совпадать.")
            }
        // Вычисляем хэш пользовательского пароля используя BCrypt
        let hash = try BCrypt.hash(user.password)
        
        // Сохраняем нового пользователя (в случае наличия пользователя вернется ошибка)
        return User(id: nil, name: user.name, email: user.email, passwordHash: hash)
                .save(on: req)
        }.map { user in
            // Возвращаем JSON с телом структуры UserResponse
            return try UserResponse(id: user.requireID(), name: user.name, email: user.email)
        }
    }
}

// MARK: Content

/// Необходимые данные для создания пользователя.
struct CreateUserRequest: Content {
    /// Полное имя.
    var name: String
    
    /// email адрес.
    var email: String
    
    /// пароль.
    var password: String
    
    /// проверочный пароль.
    var verifyPassword: String
}

/// Структура данных пользователя для ответа на запросы.
struct UserResponse: Content {
    /// Уникальный индификатор пользователя.
    /// Не является опциональным, так как мы возвращаем существующие записи из БД.
    var id: Int
    
    /// Полное имя.
    var name: String
    
    /// email адрес.
    var email: String
}

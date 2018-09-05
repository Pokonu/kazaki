import Vapor
import Crypto
import Leaf

/// Здесь регистрируем задействуемые в приложении маршруты.
public func routes(_ router: Router) throws {
 
    // отражет индексную страницу в корне
    /*router.get { req in
        return try req.view().render("welcome")
        //return try req.make(LeafRenderer.self).render("welcome")
    }
 */
	let controller = RoutersController()
    router.get("",use: controller.root)
   
    // Основной пример "Hello, world!"
    router.get("hello",use: controller.hello)
   
    // Скажем hello при запросе '/hello/Greg'
    router.get("hello", String.parameter, use: controller.helloName)
    
    // Получаем данные из запроса и отображаем их в виде JSON
    router.get("info", use: controller.info)

    router.get("sql", use: controller.sql)
    
    let userController = UserController()
    // создаем нового пользователя и записываем в БД через POST запрос
    // данные пользователя без хеширования пароля (чистый текст)
    router.post("add", use: userController.addUser)
    
    // Вариант 3
    // создаем нового пользователя и записываем в БД через POST запрос
    // данные пользователя передаюся с хешированием пароля (кодированный)
    router.post("create", use: userController.create)
    

    // Получаем список всех пользователей в виде JSON
    router.get("users-list", use: userController.userList)
    
    // Получаем список всех пользователей в виде HTML страницы
    router.get("users-page", use: userController.showUsersList)

    // Получаем конкретного пользователя
    // /users/<id>, например /users/5
    router.get("user-id", User.parameter, use: userController.getUserById)
    
    // Основа защиты авторизациипользовательских маршрутов
    // заходим на сайт под своей учетной записью
    // /login?
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

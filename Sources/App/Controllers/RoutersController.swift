import Crypto
import Vapor
import Leaf


/// Создаем процедуры для обработки маршрутов.
/*
final class RoutersController {
	func root(_ req: Request) throws -> Future<View> {
        return try req.view().render("welcome")
	}
    
    func showUsersList(_ req: Request) throws -> Future<View> {
        let context = UserContext(users: User.query(on: req).all())
        return try req.make(LeafRenderer.self).render("users", context)
    }
}
*/

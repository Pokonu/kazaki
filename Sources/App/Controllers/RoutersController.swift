import Crypto
import Vapor
import HTTP


/// Создаем процедуры для обработки маршрутов.
struct UsersContext: Encodable {
    let users: Future<[User]>
}

final class RoutersController {
	func root(_ req: Request) throws -> Future<View> {
        return try req.view().render("welcome")
	}
    
    
    func hello(_ req: Request)throws -> String{
        return "Hello, world!"
    }
    
    func helloName(_ req: Request) throws -> Future<View> {
        return try req.view().render("hello", ["name": req.parameters.next(String.self)])
    }
    
    func info(_ req: Request) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        struct DataPrint: Content {
            var place: String
            var framework: String
            var time: String
        }
        let date = Date()
        let calendar = Calendar.current
        
        let hours = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        let time = "\(hours):\(minutes):\(seconds)"
        let jsonData = try encoder.encode(DataPrint(place: "Дом", framework: "Vapor", time: time))
        
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }
    struct PostgreSQLVersion: Codable {
        let version: String
    }
    
    func sql(_ req: Request) throws -> Future<String> {
        return req.withPooledConnection(to: .psql) { conn in
            return conn.raw("SELECT version();").all(decoding: PostgreSQLVersion.self)
            }.map { rows in
                return rows[0].version
            }
    }
    
}

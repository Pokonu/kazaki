import HTTP
import Vapor
import XCTest
//import Testing

// Примеры написания тестов
// https://github.com/vapor/vapor/tree/master/Tests/VaporTests

// Список функций для проверки свойств объектов
// http://iosunittesting.com/xctest-assertions/
// https://developer.apple.com/documentation/xctest


final class AppTests: XCTestCase {
    func testNothing() throws {
        
        let app = try Application()
        let req = Request(using: app)
        
        req.http.body = """
        {
            "hello": "world"
        }
        """.convertToHTTPBody()
        req.http.contentType = .json
        try XCTAssertEqual(req.content.get(at: "hello").wait(), "world")
    }

    static let allTests = [
        ("testNothing", testNothing)
    ]
}

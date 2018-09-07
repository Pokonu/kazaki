import App
import XCTest
@testable import Vapor


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

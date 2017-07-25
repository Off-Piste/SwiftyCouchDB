import XCTest
@testable import SwiftyCouchDB

class SwiftyCouchDBTests: XCTestCase {

    func testInvalidConnection() {
        XCTAssertThrowsError(try CouchAuth())
        XCTAssertThrowsError(try CouchDatabase(name: "users", design: "users"))
    }

    static var allTests = [
        ("testExample", testInvalidConnection),
    ]
}

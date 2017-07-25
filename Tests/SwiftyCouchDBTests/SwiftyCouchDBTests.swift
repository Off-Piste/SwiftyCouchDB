import XCTest
@testable import SwiftyCouchDB

class IntitalisationTests: XCTestCase {

    func testThrowingInitalisation() {
        // Needs to be nil to throw the error
        ConnectionPropertiesManager.connectionProperties = nil

        XCTAssertThrowsError(try CouchAuth())
        XCTAssertThrowsError(try CouchDatabase(name: "users", design: "users"))
    }

    func testValidInitalisation() {
        ConnectionPropertiesManager
            .connectionProperties = ConnectionProperties(
                host: "127.0.0.1",
                port: 5984,
                secured: false
        )

        XCTAssertNoThrow(try CouchAuth())
        XCTAssertNoThrow(try CouchDatabase(name: "users", design: "users"))

        ConnectionPropertiesManager.connectionProperties = nil
    }

    func testCreatingAndDeletingDatabase() {
        ConnectionPropertiesManager
            .connectionProperties = ConnectionProperties(
                host: "127.0.0.1",
                port: 5984,
                secured: false
        )

        let client = CouchDBClient(connectionProperties: ConnectionProperties(
            host: "127.0.0.1",
            port: 5984,
            secured: false
            )
        )

        let db = try! CouchDatabase(name: "test")
        db.create(callback: { (error) in
            if let error = error {
                XCTFail("Creating DB Error: \(error._code), reason: \(error.localizedDescription)")
            }

            print(">> Successful DB creation")

            db.delete(callback: { (error) in
                if let error = error {
                    XCTFail("Creating DB Error: \(error._code), reason: \(error.localizedDescription)")
                }

                print(">> Successful DB deletion")
            })
        })
    }

    static var allTests = [
        ("testThrowingInitalisation", testThrowingInitalisation),
        ("testCreatingAndDeletingDatabase", testCreatingAndDeletingDatabase),
        ("testValidInitalisation", testValidInitalisation)
    ]
}

import XCTest
@testable import SwiftyCouchDB

class IntitalisationTests: XCTestCase {

    var database: Database!

    override func setUp() {
        print(">> Setting Up")

        Utils.connectionProperties = .default

        self.database = try! Database("todolist")
    }

    override func tearDown() {
        print(">> Finished")
        
        Utils.connectionProperties = nil
    }

    func testCallbackDelete() {
        Utils.connectionProperties = .default
        
        self.database.create { (database, error) in
            if let error = error {
                XCTFail(for: error)
            } else {
                database.delete(callback: { (error) in
                    if let error = error {
                        XCTFail(for: error)
                    }
                })
            }
        }
    }

    func testDoesNotExists() {
        Utils.connectionProperties = .default

        self.database.exists { (error) in
            if let error = error {
                XCTFail(for: error)
            } else {
                XCTFail("Database should not exist")
            }
        }
    }


    func testThrowingInitalisation() {
        // Needs to be nil to throw the error
        Utils.connectionProperties = nil

        XCTAssertThrowsError(try Database("dbname"))
        XCTAssertThrowsError(try UserDatabase())

        Utils.connectionProperties = .default
    }

    func testValidInitalisation() {
        Utils.connectionProperties = .default

        XCTAssertNoThrow(try Database("dbname"))
        XCTAssertNoThrow(try UserDatabase())

        Utils.connectionProperties = nil
    }

    func testDatabaseInit() {
        Utils.connectionProperties = .default

        XCTAssertNoThrow(try Database { try UserDatabase() })
        XCTAssertNoThrow(try Database(database: try UserDatabase()))

        let db1 = try! UserDatabase()
        let db2 = try! Database(database: db1)
        XCTAssertEqual(db1, db2)

        Utils.connectionProperties = nil
    }

}

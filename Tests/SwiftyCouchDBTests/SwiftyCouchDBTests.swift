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
            if error == nil { XCTFail("Database should not exist") }
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

    func testProperties() {
        let user: DatabaseObject = User()
        let type1 = CouchDBPropertyType(for: user)
        XCTAssertEqual(type1.rawValue, 6)

        let array: Array<DatabaseObject> = []
        let type2 = CouchDBPropertyType(for: array)
        XCTAssertEqual(type2.rawValue, 3)

        let dict: Dictionary<DatabaseObject, String> = [:]
        let type3 = CouchDBPropertyType(for: dict)
        XCTAssertEqual(type3.rawValue, 4)

        let type4: PropertyType = 5
        XCTAssertEqual(type4.rawValue, 5)

        let property1: CouchDBProperty<Int> = CouchDBProperty(key: "age", value: 55, parentObject: user, isOptional: false)
        let property2: CouchDBProperty<Int> = CouchDBProperty(key: "age", value: 22, parentObject: user, isOptional: false)
        XCTAssertNotEqual(property1, property2)
    }

}

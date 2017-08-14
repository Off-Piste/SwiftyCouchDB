import XCTest
@testable import SwiftyCouchDB

class DatabaseTests: XCTestCase {

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

    func test__Database__Creation_And_Deletion__Should_Pass() {
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

    func test__Database__Invalid_Exists__Should_Pass() {
        Utils.connectionProperties = .default

        self.database.exists { (error) in
            if error == nil { XCTFail("Database should not exist") }
        }
    }


    func test__Database__Invalid_Initalisation__Should_Throw() {
        Utils.connectionProperties = nil

        XCTAssertThrowsError(try Database("dbname"))
        XCTAssertThrowsError(try UserDatabase())

        Utils.connectionProperties = .default
    }

    func test__Database__Valid_Initalisation__Should_Not_Throw() {
        Utils.connectionProperties = .default

        XCTAssertNoThrow(try Database("dbname"))
        XCTAssertNoThrow(try UserDatabase())

        Utils.connectionProperties = nil
    }

    func test__Database__Convenience_Init__Should_Not_Throw() {
        Utils.connectionProperties = .default

        XCTAssertNoThrow(try Database { try UserDatabase() })
        XCTAssertNoThrow(try Database(database: try UserDatabase()))

        let db1 = try! UserDatabase()
        let db2 = try! Database(database: db1)
        XCTAssertEqual(db1, db2)

        Utils.connectionProperties = nil
    }

    func test__Database__Object_Creation__Should_Pass() {
        Utils.connectionProperties = .default

        let exp = self.expectation(description: #function)

        let newItem = TodoItem()
        newItem.datestamp = Date().timeIntervalSince1970
        newItem.id = UUID().uuidString

        try! Database("todolist").create(with: newItem, callback: { (database, error) in
            if let error = error { XCTFail(for: error) }
            
            database.delete(callback: { (error) in
                if let error = error { XCTFail(for: error) }
                exp.fulfill()
            })
        })

        self.waitForExpectations(timeout: 40, handler: nil)
        Utils.connectionProperties = nil
    }

    func test__database__adding_products__should_pass() {
        Utils.connectionProperties = .default

        let exp = self.expectation(description: #function)

        let item1 = TodoItem()
        item1.datestamp = Date().timeIntervalSince1970
        item1.id = UUID().uuidString

        let item2 = TodoItem()
        item2.datestamp = Date().timeIntervalSince1970
        item2.id = UUID().uuidString

        let objects: [TodoItem] = [item1, item2]

        try! Database("todolist").create(callback: { (db, error) in
            if let error = error { XCTFail(for: error); exp.fulfill() }
            else {
                db.add(objects, callback: { (error) in
                    if let error = error { XCTFail(for: error) }

                    db.delete(callback: { (error) in
                        if let error = error { XCTFail(for: error) }
                        exp.fulfill()
                    })
                })
            }
        })

        self.waitForExpectations(timeout: 40, handler: nil)
        Utils.connectionProperties = nil
    }

}

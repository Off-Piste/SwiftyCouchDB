//
//  DatabaseReference.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 09.08.17.
//
//

import XCTest
@testable import SwiftyCouchDB

class TodoItem: DatabaseObject {

    dynamic var id: String = ""

    dynamic var type: String = "TodoItem"

    dynamic var datestamp: TimeInterval = 0

}

class DatabaseReferenceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_Normal_ForReferenceCreation() {
        Utils.connectionProperties = .default

        let db = try! Database("todolist")

        let ref1 = db.reference
        let ref2 = DatabaseReference(db) // internal method not used by public

        XCTAssertEqual(ref1, ref2)
    }

    func test_Normal_ForParent() {
        Utils.connectionProperties = .default

        let db = try! Database("todolist")
        let ref = db.reference["data", "owner", "address", "postcode"]

        XCTAssertEqual(ref.__childrenCount, 4)
        XCTAssertEqual(ref._child, "postcode")

        let ref1 = ref.parent
        XCTAssertEqual(ref1?.__childrenCount, 3)
        XCTAssertEqual(ref1?._child, "address")

        let ref2 = ref1?.parent
        XCTAssertEqual(ref2?.__childrenCount, 2)
        XCTAssertEqual(ref2?._child, "owner")

        let ref3 = ref2?.parent
        XCTAssertEqual(ref3?.__childrenCount, 1)
        XCTAssertEqual(ref3?._child, "data")

        let ref4 = ref3?.parent
        XCTAssertEqual(ref4?.__childrenCount, 0)
        XCTAssertEqual(ref4?._child, nil)

        let ref5 = ref4?.parent
        XCTAssertEqual(ref5, nil)

        Utils.connectionProperties = nil
    }

    func test_Normal_ForDatabaseChildren() {
        Utils.connectionProperties = .default

        let db1 = try! UserDatabase()
        let db2 = try! Database(database: db1)
        var ref1 = db1.reference
        var ref2 = db2.reference

        let child1 = ref1.children("type")._child
        let child2 = ref2.children("type")._child
        XCTAssertEqual(child1, child2)

        let child3 = ref1.children("worker")._child
        XCTAssertEqual(child3, "worker")
        XCTAssertNotEqual(child1, child3)

        let ref2Count = ref1["ants", "bees", "elephants"].__childrenCount
        let lastChild = ref1._child
        XCTAssertEqual(ref2Count, 5)
        XCTAssertEqual(lastChild, "elephants")

        ref1 = ref1.root
        ref2 = ref1.root
        XCTAssertEqual(ref1._child, nil)
        XCTAssertEqual(ref2._child, nil)

        Utils.connectionProperties = nil
    }
    
    func test_Performance_ForObjectCreation() {
        // This is an example of a performance test case.
        self.measure {
            Utils.connectionProperties = .default

            let exp = self.expectation(description: #function)

            let newItem = TodoItem()
            newItem.datestamp = Date().timeIntervalSince1970
            newItem.id = UUID().uuidString

            try! Database("todolist").reference.create(newItem, callback: { (obj, error) in
                exp.fulfill()
            })

            self.waitForExpectations(timeout: 40, handler: nil)
        }
    }
    
}

//
//  DatabaseReference.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 09.08.17.
//
//

import XCTest
@testable import SwiftyCouchDB

@objcMembers class TodoItem: DatabaseObject {

    dynamic var id: String = ""

    dynamic var type: String = "TodoItem"

    dynamic var datestamp: TimeInterval = 0

    override var database: Database? {
        return try? Database("todolist")
    }

}

class DatabaseReferenceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
//    func test__database_reference__initalisation__should_pass() {
//        Utils.connectionProperties = .default
//
//        let db = try! Database("todolist")
//
//        let ref1 = db.reference
//        let ref2 = DatabaseReference(db) // internal method not used by public
//
//        XCTAssertEqual(ref1, ref2)
//
//        Utils.connectionProperties = nil
//    }
//
//    func test_database_reference__initalisation__should_not_throw() {
//        Utils.connectionProperties = .default
//
//        let item = TodoItem()
//        item.id = UUID().uuidString
//        item.datestamp = Date().timeIntervalSince1970
//
//        let db = try! Database("todolist")
//        XCTAssertNoThrow(try db.reference(for: item))
//
//        Utils.connectionProperties = nil
//    }
//
//    func test__database_reference__parent__should_pass() {
//        Utils.connectionProperties = .default
//
//        let db = try! Database("todolist")
//        let ref = db.reference["data", "owner", "address", "postcode"]
//
//        XCTAssertEqual(ref.__childrenCount, 4)
//        XCTAssertEqual(ref.__child, "postcode")
//
//        let ref1 = ref.parent
//        XCTAssertEqual(ref1?.__childrenCount, 3)
//        XCTAssertEqual(ref1?.__child, "address")
//
//        let ref2 = ref1?.parent
//        XCTAssertEqual(ref2?.__childrenCount, 2)
//        XCTAssertEqual(ref2?.__child, "owner")
//
//        let ref3 = ref2?.parent
//        XCTAssertEqual(ref3?.__childrenCount, 1)
//        XCTAssertEqual(ref3?.__child, "data")
//
//        let ref4 = ref3?.parent
//        XCTAssertEqual(ref4?.__childrenCount, 0)
//        XCTAssertEqual(ref4?.__child, nil)
//
//        let ref5 = ref4?.parent
//        XCTAssertEqual(ref5, nil)
//
//        Utils.connectionProperties = nil
//    }
//
//    func test__database_reference__children__should_pass() {
//        Utils.connectionProperties = .default
//
//        let db1 = try! UserDatabase()
//        let db2 = try! Database(database: db1)
//        var ref1 = db1.reference
//        var ref2 = db2.reference
//
//        let child1 = ref1.children("type").__child
//        let child2 = ref2.children("type").__child
//        XCTAssertEqual(child1, child2)
//
//        let child3 = ref1.children("worker").__child
//        XCTAssertEqual(child3, "worker")
//        XCTAssertNotEqual(child1, child3)
//
//        let ref2Count = ref1["ants", "bees", "elephants"].__childrenCount
//        let lastChild = ref1.__child
//        XCTAssertEqual(ref2Count, 5)
//        XCTAssertEqual(lastChild, "elephants")
//
//        ref1 = ref1.root
//        ref2 = ref1.root
//        XCTAssertEqual(ref1.__child, nil)
//        XCTAssertEqual(ref2.__child, nil)
//
//        Utils.connectionProperties = nil
//    }
    
}

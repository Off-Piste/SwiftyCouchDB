//
//  SwiftyCouchDBTests.swift
//  SwiftyCouchDBTests
//
//  Created by Harry Wright on 24.10.17.
//

import XCTest
import SwiftyCouchDB

class DatabaseTests: BaseTestCase {

    func testThatDatabaseNameIsValid() {
        XCTAssertNoThrow(try Database("products"))
        XCTAssertNoThrow(try Database("a_valid_database_name"))
        XCTAssertNoThrow(try Database("wag+wan"))
    }

    func testThatDatabaseNameIsInvalid() {
        XCTAssertThrowsError(try Database("1_products"))
        XCTAssertThrowsError(try Database("a.invalid.database.name"))
        XCTAssertThrowsError(try Database("IS_THIS_INVALID"))
    }

    func testThatDatabaseURLisValid() {
        XCTAssertNoThrow(try Database(url: "http://localhost:8080/products"))
        XCTAssertNoThrow(try Database(url: "http://www.google.co.uk/a_valid_database_name"))
        XCTAssertNoThrow(try Database(url: "http://hehe:46445@validurl.co.uk/wag+wan"))
    }

    /// We called: `curl -X PUT 127.0.0.1:5984/test_deletion`
    /// before the tests start so we don't have to do:
    ///
    /// ```swift
    /// database.create { (database, _) in
    ///     database?.delete { ... }
    /// }
    /// ```
    func testThatValidDatabaseDeletes() {
        async { (exp) in
            // Given
            let database = try Database("test_deletion")

            // When
            database.delete(callback: { (success, error) in
                // Then
                XCTAssert(success)
                XCTAssertNil(error)

                exp.fulfill()
            })
        }
    }

    /// We called: `curl -X PUT 127.0.0.1:5984/test_exists`
    /// before the tests start so we don't have to do:
    ///
    /// ```swift
    /// database.create { (database, _) in
    ///     database?.exists { ... }
    /// }
    /// ```
    func testThatValidDatabaseExists() {
        async { (exp) in
            // Given
            let database = try Database("test_exists")

            // When
            database.exists(callback: { (exists, error) in
                // Then
                XCTAssert(exists)
                XCTAssertNil(error)

                exp.fulfill()
            })
        }
    }

    func testThatInvalidValidDatabaseDoesNotExist() {
        async { (exp) in
            // Given
            let database = try Database("test_does_not_exists")

            // When
            database.exists(callback: { (exists, error) in
                // Then
                XCTAssert(!exists)
                XCTAssertNil(error)

                exp.fulfill()
            })
        }
    }
    
}

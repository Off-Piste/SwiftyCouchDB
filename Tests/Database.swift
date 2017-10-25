//
//  SwiftyCouchDBTests.swift
//  SwiftyCouchDBTests
//
//  Created by Harry Wright on 24.10.17.
//

import XCTest
import SwiftyCouchDB

class DatabaseTests: BaseTestCase {

    /// We called: `curl -X PUT 127.0.0.1:5984/test_exists`
    /// before the tests start so we don't have to do:
    ///
    /// ```swift
    /// database.create { (database, _) in
    ///     database?.exists { ... }
    /// }
    /// ```
    func test_exists() {
        async { (exp) in
            // Given
            let database = try Database(#function)

            // When
            database.exists(callback: { (exists, error) in
                // Then
                XCTAssert(exists)
                XCTAssertNil(error)

                exp.fulfill()
            })
        }
    }

    /// We called: `curl -X DELETE 127.0.0.1:5984/test_deletion`
    /// before the tests start so we don't have to do:
    ///
    /// ```swift
    /// database.create { (database, _) in
    ///     database?.delete { ... }
    /// }
    /// ```
    func test_deletion() {
        async { (exp) in
            // Given
            let database = try Database(#function)

            // When
            database.delete(callback: { (success, error) in
                // Then
                XCTAssert(success)
                XCTAssertNil(error)

                exp.fulfill()
            })
        }
    }
    
}

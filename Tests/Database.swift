//
//  SwiftyCouchDBTests.swift
//  SwiftyCouchDBTests
//
//  Created by Harry Wright on 24.10.17.
//

import XCTest
import SwiftyCouchDB

class DatabaseTests: BaseTestCase {
    
    func test_exists() {
        async { (exp) in
            let database = try Database(#function)

            database.exists(callback: { (exists, error) in
                XCTAssert(exists)
                XCTAssertNil(error)

                exp.fulfill()
            })
        }
    }
    
}

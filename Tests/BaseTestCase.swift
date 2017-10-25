//
//  BaseTestCase.swift
//  SwiftyCouchDBTests
//
//  Created by Harry Wright on 24.10.17.
//

import XCTest
import SwiftyCouchDB
import HeliumLogger

class BaseTestCase: XCTestCase {

    var timeout: TimeInterval = 40

    override func setUp() {
        super.setUp()

        HeliumLogger.use()
    }

    func async(for description: String = #function, callback: (XCTestExpectation) throws -> Void) {
        let exp = self.expectation(description: description)
        do { try callback(exp) }
        catch { XCTFail() }

        self.waitForExpectations(timeout: timeout, handler: nil)
    }

}

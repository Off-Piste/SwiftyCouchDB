//
//  XCTTests+DB.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 09.08.17.
//
//

import XCTest
import SwiftyCouchDB

func XCTFail(for error: Error, file: StaticString = #file, line: UInt = #line) {
    // 99% of the time will be caused due to the server not running,
    // so don't fail the test due to it, as some times the tests will
    // just be for the remaining code and i press all tests to save me
    // time
    if error._code == 0 {
        return
    }

    XCTFail("Reason: \(error.localizedDescription), code: \(error._code)", file: file, line: line)
}

func XCTAssertEqual(_ expression1: JSONSubscriptType?, _ expression2: JSONSubscriptType?, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
    XCTAssertTrue(expression1 == expression2, message, file: file, line: line)
}

func XCTAssertNotEqual(_ expression1: JSONSubscriptType?, _ expression2: JSONSubscriptType?, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
    XCTAssertFalse(expression1 == expression2, message, file: file, line: line)
}

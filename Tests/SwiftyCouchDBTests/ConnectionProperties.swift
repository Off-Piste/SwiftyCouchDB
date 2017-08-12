//
//  ConnectionPropertiesTest.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 12.08.17.
//
//

import XCTest
@testable import SwiftyCouchDB

class ConnectionPropertiesTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test__Basic_Initalisation__Should_Pass() {
        let cp = ConnectionProperties(host: "localhost", port: 8080, secured: false)

        XCTAssertEqual(cp.host, "localhost")
        XCTAssertEqual(cp.HTTPProtocol, "http")
        XCTAssertEqual(cp.port, 8080)
        XCTAssertEqual(cp.URL, "http://localhost:8080")
    }

    func test__Complicated_Initalisation__Should_Pass() {
        let cp = ConnectionProperties(
            host: "100.10.8.0",
            port: 1010,
            secured: true,
            username: "hello",
            password: "world"
        )

        XCTAssertEqual(cp.host, "100.10.8.0")
        XCTAssertEqual(cp.HTTPProtocol, "https")
        XCTAssertEqual(cp.URL, "https://hello:world@100.10.8.0:1010")

        let newUser = User()
        newUser.username = "HarryTWright"
        newUser.password = "1234567890"
        newUser.email = "harrytwright@gmail.com"

        XCTAssertThrowsError(try DatabaseObjectUtil.DBObjectScheme(for: newUser))
    }


    
}

//
//  DatabaseObjectSchemeTests.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 12.08.17.
//
//

import XCTest
@testable import SwiftyCouchDB

class DatabaseObjectSchemeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test__invalid_object__creation__should_throw() {
        let user = User()

        XCTAssertThrowsError(try DatabaseObjectUtil.DBObjectScheme(for: user))
    }


    func test__valid_object__creation__should_not_throw() {
        let user = User()
        user.email = "haroldtomwright@gmail.com"
        user.id = UUID().uuidString
        
        XCTAssertNoThrow(try DatabaseObjectUtil.DBObjectScheme(for: user))
    }

    func test__valid_object__properties__should_pass() {
        let user = User()
        user.id = UUID().uuidString

        let scheme = try! DatabaseObjectUtil.DBObjectScheme(for: user)
        XCTAssertEqual(scheme.className, "User")
        XCTAssertEqual(scheme.properties.count, 4)
        XCTAssertEqual((scheme.id.value as! String), user.id)
    }

    func test__valid_scheme__equatable__should_pass() {
        let user = User()
        user.id = UUID().uuidString

        var scheme = try! DatabaseObjectUtil.DBObjectScheme(for: user)
        let scheme2 = try! DatabaseObjectUtil.DBObjectScheme(for: user)

        XCTAssertEqual(scheme, scheme2)

        user.email = "haroldtomwright@gmail.com"
        scheme = try! DatabaseObjectUtil.DBObjectScheme(for: user)

        XCTAssertNotEqual(scheme, scheme2)
    }

    func test__valid_scheme__json() {
        let user = User()
        user.id = UUID().uuidString
        user.email = "haroldtomwright@gmail.com"
        user.password = "1234567890".data(using: .utf8)!.base64EncodedString()
        user.username = "harrytwright"
        user.roles.append("Admin")

        let json = DatabaseObjectUtil.DBObjectJSON(from: try! user.scheme())
        XCTAssertEqual(json["data"].count, 4)
        XCTAssertEqual(json["data"]["email"].stringValue,"haroldtomwright@gmail.com")
    }
}

//
//  DocumentTest.swift
//  SwiftyCouchDBTests
//
//  Created by Harry Wright on 10.11.17.
//

import XCTest
import SwiftyCouchDB

class DocumentTest: BaseTestCase {

    func testThatAddingToArrayPasses() {
        self.async { (exp) in
            let userList = UserList(_id: "qwertyuiop", list: CodableArray<User>())
            let user = User(_id: "qwertyuiop", username: "qwertyuiop", email: "qwertyuiop@email.com")

            userList.addChange(user, forKeyPath: \UserList.list, callback: { (change, document) in
                switch change {
                case .changes: break
                case .error(let error): XCTFail(error.localizedDescription)
                default: XCTFail()
                }
                exp.fulfill()
            })

        }
    }
    
}

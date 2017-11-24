//
//  DocumentTest.swift
//  SwiftyCouchDBTests
//
//  Created by Harry Wright on 10.11.17.
//

import XCTest
import SwiftyCouchDB

extension Database.Design {
    static var connections = Database.Design("_design/connctions")
}

class DocumentTest: BaseTestCase {

    func testThatAddingToArrayPasses() {
        self.async { (exp) in
//            let userList = UserList(_id: "qwertyuiop", list: CodableArray<User>())
//            let user = User(_id: "qwertyuiop", username: "qwertyuiop", email: "qwertyuiop@email.com")
//
//            userList.addChange(user, forKeyPath: \UserList.list, callback: { (change, document) in
//                switch change {
//                case .changes: break
//                case .error(let error): XCTFail(error.localizedDescription)
//                default: XCTFail()
//                }
//                exp.fulfill()
//            })


            let allConnections = DBDesignView(/*
                name: */"all"/*,
                function: .map("function(doc) { if (doc.device.os.name === 'iOS') { emit(doc) } }")*/
            )

            try! Database("analytics").queryByView(allConnections, in: .connections, callback: { (json, error) in
                dump(error)
                dump(json)

                exp.fulfill()

//                PlaygroundPage.current.finishExecution()
            })

//            try! Database("analytics").addFunctions(
//                [allConnections],
//                to: .connections,
//                callback: { (change) in
//
//                    switch change {
//                    case .error(let error): XCTFail(error.localizedDescription)
//                    default: break
//                    }
//
//                    exp.fulfill()
//                }
//            )
        }
    }
    
}

//
//  Models.swift
//  SwiftyCouchDBTests
//
//  Created by Harry Wright on 30.10.17.
//

import Foundation
import SwiftyCouchDB

struct User: DBDocument {
    
    var _id: String = ""

    var username: String = ""

    var email: String = ""

    static var database: Database? {
        return try? Database("test_adding")
    }

}

struct UpdatingUser: DBDocument {
    
    var _id: String = ""
    
    var username: String = ""
    
    var email: String = ""
    
    static var database: Database? {
        return try? Database("test_retrieve")
    }
}

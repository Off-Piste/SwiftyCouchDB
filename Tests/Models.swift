//
//  Models.swift
//  SwiftyCouchDBTests
//
//  Created by Harry Wright on 30.10.17.
//

import Foundation
import SwiftyCouchDB

func change<Change: Codable, Document: DBDocument, Sequence: RangeReplaceableCollection>(
    _ change: Change,
    in document: inout Document,
    forKeyPath keyPath: WritableKeyPath<Document, Sequence>
    ) where Sequence.Element == Change
{
    document[keyPath: keyPath].append(change)
}

struct User: DBDocument {
    
    var _id: String = ""

    var username: String = ""

    var email: String = ""

    static var database: Database? {
        return try? Database("test_adding")
    }

}

///
/// Example:
/// ```json
/// {
///     "_id" : "qwertyuiop",
///     "list" : [
///         {
///             "_id": "abc",
///             "username" : "qwerty",
///             "email" : "qwerty@email.com"
///         }
///     ]
/// }
/// ```
struct UserList: DBDocument {

    var _id: String = UUID().uuidString

    var list: CodableArray<User> = []

    static var database: Database? {
        return try? Database("test_add_change")
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

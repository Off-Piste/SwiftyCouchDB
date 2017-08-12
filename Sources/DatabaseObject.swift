//
//  DatabaseObject.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 08.08.17.
//
//

import Foundation

func DatabaseObjectAreEqual(_ lhs: DatabaseObject, rhs: DatabaseObject) -> Bool {
    if let lhsScheme = try? lhs.scheme(), let rhsScheme = try? rhs.scheme() {
        return lhs.className == rhs.className && lhsScheme == rhsScheme
    }
    return false
}

open class DatabaseObject: DatabaseObjectBase {

    private var requiredDBProperties: [String] = ["_id", "_rev", "type", "id"]

    func scheme() throws -> DatabaseObjectScheme {
        return try DatabaseObjectUtil.DBObjectScheme(for: self)
    }

}

extension DatabaseObject {

    open func hiddenProperties() -> [String] { return [] }

    open func nonDataProperties() -> [String] { return [] }

    open override func isEqual(_ object: Any?) -> Bool {
        if object is DatabaseObject {
            return DatabaseObjectAreEqual(self, rhs: (object as! DatabaseObject))
        }

        return super.isEqual(object)
    }
    
}

public final class User: DatabaseObject {

    dynamic var id: String = ""

    dynamic var roles: [String] = []

    dynamic var type: String = "user"

    dynamic var password: String = ""

    dynamic var username: String = ""

    dynamic var email: String = ""

}

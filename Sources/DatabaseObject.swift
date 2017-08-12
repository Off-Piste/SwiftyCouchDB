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

/** */
open class DatabaseObject: DatabaseObjectBase {

    private var requiredDBProperties: [String] = ["_id", "_rev", "type", "id"]

    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    /// - Throws: <#throws value description#>
    func scheme() throws -> DatabaseObjectScheme {
        return try DatabaseObjectUtil.DBObjectScheme(for: self)
    }

}

extension DatabaseObject {

    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    open func hiddenProperties() -> [String] { return [] }

    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    open func nonDataProperties() -> [String] { return [] }

    /// Returns a Boolean value that indicates whether the receiver 
    /// and a given object are equal.
    ///
    /// - Parameter object: The object to be compared to the receiver. May be nil, 
    ///                     in which case this method returns false.
    /// - Returns: true if the receiver and anObject are equal, otherwise false.
    open override func isEqual(_ object: Any?) -> Bool {
        if object is DatabaseObject {
            return DatabaseObjectAreEqual(self, rhs: (object as! DatabaseObject))
        }

        return super.isEqual(object)
    }
    
}

/** */
public final class User: DatabaseObject {

    /// <#Description#>
    dynamic var id: String = ""

    /// <#Description#>
    dynamic var roles: [String] = []

    /// <#Description#>
    dynamic var type: String = "user"

    /// <#Description#>
    dynamic var password: String = ""

    /// <#Description#>
    dynamic var username: String = ""

    /// <#Description#>
    dynamic var email: String = ""

}

//
//  DatabaseObject.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 08.08.17.
//
//

import Foundation

func DatabaseObjectAreEqual(_ lhs: DatabaseObject, _ rhs: DatabaseObject) -> Bool {
    if let lhsScheme = try? lhs.scheme(), let rhsScheme = try? rhs.scheme() {
        return lhs.className == rhs.className && lhsScheme == rhsScheme
    }
    return false
}

/** */
open class DatabaseObject: DatabaseObjectBase {

    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    /// - Throws: <#throws value description#>
    final public func scheme() throws -> DatabaseObjectScheme {
        return try DatabaseObjectUtil.DBObjectScheme(for: self)
    }

}

// MARK: - Overrideable Methods
extension DatabaseObject {

    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    open func hiddenProperties() -> [String] { return [] }

    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    open func nonNestedProperties() -> [String] { return [] }

}

// MARK: - NSObject Overrides
extension DatabaseObject {

    /// Returns a Boolean value that indicates whether the receiver
    /// and a given object are equal.
    ///
    /// - Parameter object: The object to be compared to the receiver. May be nil, 
    ///                     in which case this method returns false.
    /// - Returns: true if the receiver and object are equal, otherwise false.
    open override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? DatabaseObject {
            return self.isEqual(toObject: object)
        } else {
            return super.isEqual(object)
        }
    }

    /// Returns a Boolean value that indicates whether the receiver
    /// and a given object are equal.
    ///
    /// - Parameter object: The object to be compared to the receiver. May be nil,
    ///                     in which case this method returns false.
    /// - Returns: true if the receiver and object are equal, otherwise false.
    final public func isEqual(toObject object: DatabaseObject) -> Bool {
        return DatabaseObjectAreEqual(self, object)
    }

    /// Returns a Boolean value that indicates whether the receiver is not equal 
    /// to another given object.
    ///
    /// - Parameter object: The object with which to compare the receiver.
    /// - Returns: true if the receiver is not equal to object, otherwise false.
    open override func isNotEqual(to object: Any?) -> Bool {
        return !self.isEqual(object)
    }

    /// Returns a Boolean value that indicates whether the receiver is not equal
    /// to another given object.
    ///
    /// - Parameter object: The object with which to compare the receiver.
    /// - Returns: true if the receiver is not equal to object, otherwise false.
    final public func isNotEqual(toObject object: DatabaseObject) -> Bool {
        return !DatabaseObjectAreEqual(self, object)
    }

    /// Returns a Boolean value that indicates whether the receiver is an
    /// instance of given class or an instance of any class that inherits 
    /// from that class.
    ///
    /// - Parameter aClass: A class object representing the Objective-C class to be tested.
    /// - Returns: true if the receiver is an instance of aClass or an instance of 
    ///            any class that inherits from aClass, otherwise false.
    open override func isKind(of aClass: AnyClass) -> Bool {
        return super.isKind(of: aClass)
    }

    /// Returns a Boolean value that indicates whether the receiver does 
    /// not descend from NSObject.
    ///
    /// - Returns: false if the receiver really descends from NSObject, 
    ///            otherwise true.
    open override func isProxy() -> Bool {
        return super.isProxy()
    }

    /// Returns a Boolean value that indicates whether the receiver 
    /// is an instance of a given class.
    ///
    /// - Parameter aClass: A class object representing the Objective-C class to be tested.
    /// - Returns: true if the receiver is an instance of aClass, otherwise false.
    open override func isMember(of aClass: AnyClass) -> Bool {
        return super.isMember(of: aClass)
    }

}

extension Array where Element == DatabaseObject {
    func nestedObjectDictionary() -> [[String : Any]] {
        var arr: [[String : Any]] = []
        let schemes = self.map { try? $0.scheme() }.flatMap { $0 }
        for scheme in schemes {
            let dict = [scheme.className : ["_id" : scheme.id.value]]
            arr.append(dict)
        }

        return arr
    }
}

// MARK: - User

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

//
//  DatabaseObject.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 08.08.17.
//
//

import Foundation
import SwiftyJSON
import LoggerAPI

func DatabaseObjectAreEqual(_ lhs: DatabaseObject, _ rhs: DatabaseObject) -> Bool {
    if let lhsScheme = try? lhs.scheme(), let rhsScheme = try? rhs.scheme() {
        return lhs.className == rhs.className && lhsScheme == rhsScheme
    }
    return false
}

extension Array where Element == DatabaseObjectProperty {

    func getProperty(withKey key: String) -> Element? {
        for value in self where value.key == key {
            return value
        }

        return nil
    }
}

/** */
open class DatabaseObject: DatabaseObjectBase {

    private var requiredDBProperties: [String] = ["_id", "_rev", "type", "id"]

    /// <#Description#>
    public override init() {
        super.init()
    }

    ///
    ///
    /// - Parameter values:
    required public init?(values: JSON) throws {
        super.init()

        guard let doc = values.dictionaryObject?.flatten() else {
            throw Database.Error.invalidJSON
        }

        if let id = doc["_id"] as? String {
            if id.contains("_design") { return nil }

            let scheme = try self.scheme()
//            if doc.count > (scheme.properties.count + 2) {
//                preconditionFailure("Invalid Dictionary input")
//            }

            for (key, value) in doc {
                if key == "id" || key == "_id" {
                    self.setValue(value, forKey: scheme.id.key)
                } else if key == "type" {
                    self.setValue(value, forKey: scheme.type.key)
                } else {
                    if let property = scheme.properties.getProperty(withKey: key) {
                        self.setValue(value, forKey: property.key)
                    } else {
                        continue
                    }
                }
            }
        } else {
            throw Database.Error.internalError
        }
    }

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
@objcMembers public final class User: DatabaseObject {

    /// <#Description#>
    @objc dynamic var id: String = ""

    /// <#Description#>
    @objc dynamic var roles: [String] = []

    /// <#Description#>
    @objc dynamic var type: String = "user"

    /// <#Description#>
    @objc dynamic var password: String = ""

    /// <#Description#>
    @objc dynamic var username: String = ""

    /// <#Description#>
    @objc dynamic var email: String = ""

    public override var database: Database? {
        return try? Database("_user")
    }

}

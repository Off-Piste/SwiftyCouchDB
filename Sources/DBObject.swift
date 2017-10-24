//
//  DBObject.swift
//  CouchDB
//
//  Created by Harry Wright on 22.10.17.
//  Copyright © 2017 Trolley. All rights reserved.
//

import Foundation

func isSwiftClassName(_ className: NSString) -> Bool {
    return className.range(of: ".").location != NSNotFound
}

func demangleSwiftClass(_ className: NSString) -> NSString {
    return className.substring(from: className.range(of: ".").location + 1) as NSString
}

public struct DBObjectChanges { }

/// `DBObject` is a base class for model objects representing objects stored in CouchDB.
///
/// We all know the hasle of having a messy JSON response to parse and send, or even
/// worse, update😱! So using Codable we can take all the hasle away, as long
/// as your object is Codable ready we can pass it to couchDB and it will work like a treat.
///
/// All you need to do is subclass DBObject, set the _id value and bobs your uncle, done.
@available(swift, introduced: 4.0)
@objcMembers open class DBObject: NSObject, Codable {

    /// The _id for the object, the only required property for a CouchDB document
    open var _id: String = UUID().uuidString

}

extension DBObject {

    /// The hash value.
    ///
    /// **Axiom:** `x == y` implies `x.hashValue == y.hashValue`
    ///
    /// - Note: the hash value is not guaranteed to be stable across
    ///   different invocations of the same program.  Do not persist the
    ///   hash value across program runs.
    open override var hash: Int {
        return _id.hashValue
    }

    /// Returns a Boolean value that indicates whether the receiver
    /// and a given object are equal.
    open override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? DBObject {
            do {
                let otherData = String(data: try JSONEncoder().encode(object), encoding: .utf8)
                let selfData = String(data: try JSONEncoder().encode(self), encoding: .utf8)

                return selfData == otherData
            } catch { }
        }
        return super.isEqual(object)
    }

}

extension DBObject {

    /// <#Description#>
    ///
    /// - Parameter callback: <#callback description#>
    public func add(callback: (Bool, Swift.Error?) -> Void) { }

    /// <#Description#>
    ///
    /// - Parameter callback: <#callback description#>
    public func update(callback: ([DBObjectChanges]?, Swift.Error?) -> Void) { }

    /// <#Description#>
    ///
    /// - Parameter callback: <#callback description#>
    public func delete(callback: (Bool, Swift.Error?) -> Void) { }

    /// The database for the object, defaults to:
    ///
    /// ```swift
    /// try? Database(NSStringFromClass(self).lowercased)
    /// ```
    ///
    /// - note: Can be overritten if the database is not the the class name.
    open class var database: Database? {
        let className: NSString = NSStringFromClass(self) as NSString
        let str = isSwiftClassName(className) ? demangleSwiftClass(className) : className
        return try? Database(str.lowercased as String)
    }
    
}

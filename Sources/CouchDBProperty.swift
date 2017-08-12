//
//  DatabaseObjectScheme.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 10.08.17.
//
//

import Foundation

/// The object type for the property
public enum PropertyType: Int {

    /** */
    case number = 0

    /** */
    case string = 1

    /** */
    case bool = 2

    /** */
    case array = 3

    /** */
    case dictionary = 4

    /** */
    case null = 5

    /** */
    case object = 6

    /** */
    case unknown = 7
}

extension PropertyType: ExpressibleByIntegerLiteral {

    /// A type that represents an integer literal.
    ///
    /// The standard library integer and floating-point types are all valid types
    /// for `IntegerLiteralType`.
    public typealias IntegerLiteralType = Int

    /// Creates an instance initialized to the specified integer value.
    ///
    /// Do not call this initializer directly. Instead, initialize a variable or
    /// constant using an integer literal. For example:
    ///
    ///     let x = 23
    ///
    /// In this example, the assignment to the `x` constant calls this integer
    /// literal initializer behind the scenes.
    ///
    /// - Parameter value: The value to create.
    public init(integerLiteral value: IntegerLiteralType) {
        if value > 7 {
            preconditionFailure("Value is too high")
        }

        self.init(rawValue: value)!
    }

}

func CouchDBPropertyType(for object: Any) -> PropertyType {
    if object is Int || object is Double || object is Float || object is NSNumber {
        return .number
    } else if object is String || object is NSString {
        return .string
    } else if object is [Any] {
        return .array
    } else if object is [AnyHashable: Any] {
        return .dictionary
    } else if object is Bool || object is ObjCBool {
        return .bool
    } else if object is DatabaseObject {
        return .object
    } else if object is NSNull {
        return .null
    } else {
        return .unknown
    }
}

public struct DatabaseObjectProperty {

    /// <#Description#>
    public var key: String

    /// <#Description#>
    public var value: Any

    /// <#Description#>
    public var isOptional: Bool

    internal var parent: DatabaseObject

    internal init(
        key: String,
        value: Any,
        isOptional: Bool,
        parent: DatabaseObject
        ) throws
    {
        self.key = key
        self.value = value
        self.isOptional = isOptional
        self.parent = parent

        if type == .unknown {
            throw SwiftError("Invalid JSON property type", -404)
        }
    }

}

extension DatabaseObjectProperty: Hashable {

    /// <#Description#>
    public var type: PropertyType {
        return CouchDBPropertyType(for: self.value)
    }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: DatabaseObjectProperty, rhs: DatabaseObjectProperty) -> Bool {
        return lhs.key == rhs.key &&
            lhs.type.rawValue == rhs.type.rawValue &&
            lhs.value == rhs.value
    }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int {
        return self.key.hashValue ^ self.parent.hashValue ^ self.type.hashValue
    }
}

private func == (lhs: Any?, rhs: Any?) -> Bool {
    switch (lhs, rhs) {
    case let (.some(W1), .some(W2)): return W1 == W2
    case (.none, .none): return true
    case (.none, _), (.some, _): return false
    }
}

// swiftlint:disable force_cast
private func == (lhs: Any, rhs: Any) -> Bool {
    if (lhs is Int) && (rhs is Int) {
        return (lhs as! Int) == (rhs as! Int)
    } else if (lhs is Double) && (rhs is Double) {
        return (lhs as! Double) == (rhs as! Double)
    } else if (lhs is Float) && (rhs is Float) {
        return (lhs as! Float) == (rhs as! Float)
    } else if (lhs is NSNumber) && (rhs is NSNumber) {
        return (lhs as! NSNumber).isEqual(to: rhs as! NSNumber)
    } else if (lhs is NSString) && (rhs is NSString) {
        return (lhs as! NSString).isEqual(rhs as! NSString)
    } else if (lhs is String) && (rhs is String) {
        return (lhs as! String) == (rhs as! String)
    } else if (lhs is [Any]) && (rhs is [Any]) {
        return (lhs as! NSArray).isEqual(to: rhs as! [Any])
    } else if (lhs is [AnyHashable: Any]) && (rhs is [AnyHashable: Any]) {
        return (lhs as! [AnyHashable: Any]) == (rhs as! [AnyHashable: Any])
    } else if (lhs is NSNull) && (rhs is NSNull) {
        return true
    } else if (lhs is DatabaseObject) && (rhs is DatabaseObject) {
        return (lhs as! DatabaseObject) == (rhs as! DatabaseObject)
    } else {
        return false
    }
}
// swiftlint:enable force_cast

private func != (lhs: Any, rhs: Any) -> Bool {
    return !(lhs == rhs)
}


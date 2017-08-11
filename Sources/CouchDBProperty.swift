//
//  DatabaseObjectScheme.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 10.08.17.
//
//

import Foundation

public enum PropertyType: Int {
    case number = 0
    case string = 1
    case bool = 2
    case array = 3
    case dictionary = 4
    case null = 5
    case object = 6
    case unknown = 7
}

extension PropertyType: ExpressibleByIntegerLiteral {

    public typealias IntegerLiteralType = Int

    public init(integerLiteral value: IntegerLiteralType) {
        if value > 7 {
            preconditionFailure("Value is too high")
        }

        self.init(rawValue: value)!
    }

}

func CouchDBPropertyType<Object: JSONAbleProperty>(for object: Object) -> PropertyType {
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

struct CouchDBProperty<Property: JSONAbleProperty> {

    var key: String

    var value: Property

    var parentObject: DatabaseObject

    var isOptional: Bool

    var touple: (key: String, value: Property) {
        return (key: self.key, value: self.value)
    }

    var type: PropertyType {
        return CouchDBPropertyType(for: self.value)
    }
}

extension CouchDBProperty : Hashable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: CouchDBProperty, rhs: CouchDBProperty) -> Bool {
        return lhs.key == rhs.key &&
            lhs.value == rhs.value &&
            lhs.type.rawValue == rhs.type.rawValue &&
            lhs.isOptional == rhs.isOptional
    }

    var hashValue: Int {
        return self.key.hashValue ^ self.isOptional.hashValue
    }
}

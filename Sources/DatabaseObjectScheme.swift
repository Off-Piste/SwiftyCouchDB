//
//  DatabaseObjectScheme.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 10.08.17.
//
//

import Foundation

/** */
public struct DatabaseObjectScheme: Hashable {

    /// <#Description#>
    public var id: DatabaseObjectProperty

    /// <#Description#>
    public var type: DatabaseObjectProperty

    /// <#Description#>
    public var properties: [DatabaseObjectProperty]

    /// <#Description#>
    public var className: String

    internal init(
        _ id: DatabaseObjectProperty,
        type: DatabaseObjectProperty,
        properties: [DatabaseObjectProperty],
        object: DatabaseObject
        )
    {
        self.id = id
        self.type = type
        self.properties = properties
        self.className = object.className
    }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: DatabaseObjectScheme, rhs: DatabaseObjectScheme) -> Bool {
        return lhs.id == rhs.id &&
            lhs.type == rhs.type &&
            lhs.properties == rhs.properties
    }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int {
        return id.hashValue ^ type.hashValue
    }

}

func unwrap<T>(_ any: T) -> Any {
    let mirror = Mirror(reflecting: any)
    guard mirror.displayStyle == .optional, let first = mirror.children.first else {
        return any
    }
    return first.value
}

func isOptional<T>(_ any: T) -> Bool {
    let mirror = Mirror(reflecting: any)
    guard mirror.displayStyle == .optional, mirror.children.first != nil else {
        return false
    }
    return true
}

extension Array where Element == DatabaseObjectProperty {
    func property(for key: String) -> DatabaseObjectProperty? {
        for object in self {
            if object.key == key {
                if object.type == .null { return nil }
                return object
            }
        }

        return nil
    }
}

precedencegroup BooleanPrecedence { associativity: left }
infix operator ^^ : BooleanPrecedence

func ^^(lhs: Bool, rhs: Bool) -> Bool {
    return lhs != rhs
}

internal struct DatabaseObjectUtil {

    static func DBProperties(for object: DatabaseObject) -> Array<DatabaseObjectProperty> {
        return Mirror(reflecting: object).children.filter {
            $0.label != nil || CouchDBPropertyType(for: $0.value) != .unknown
            }.map {
                try! DatabaseObjectProperty(
                    key: $0.label!,
                    value: $0.value,
                    isOptional: isOptional($0.value),
                    parent: object
                )
        }
    }

    static func DBObjectScheme(for object: DatabaseObject) throws -> DatabaseObjectScheme {
        let fullProperties = DBProperties(for: object)
        let properties = fullProperties.filter {
            if ($0.key == "type") || ($0.key == "id") { return false } else { return true }
        }

        guard let id = fullProperties.property(for: "id"),
            let type = fullProperties.property(for: "type") else {
                throw SwiftError("ID and Type are both needed for CouchDB", -200)
        }

        try validate(id: id, type: type)

        return DatabaseObjectScheme(id, type: type, properties: properties, object: object)
    }

    static func validate(id: DatabaseObjectProperty, type: DatabaseObjectProperty) throws {
        if !(id.type == .string) && !(type.type == .string) {
            throw SwiftError("ID and Type must be string", -201)
        }

        if ((id.value as! String).isEmpty ^^ (type.value as! String).isEmpty) ||
            ((id.value as! String).isEmpty && (type.value as! String).isEmpty) {
            throw SwiftError("ID and Type must have a value and not be nil", -202)
        }
    }
}

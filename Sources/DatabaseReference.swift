//
//  DatabaseReference.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 08.08.17.
//
//

import Foundation
import LoggerAPI
import SwiftyJSON

/** */
public struct DatabaseReference {

    fileprivate var __file: String?

    fileprivate var __design: String?

    internal var database: Database

    internal var __children: [JSONSubscriptType] = {
        var seq: [JSONSubscriptType] = []; return seq
    }()

    internal var __child: JSONSubscriptType? {
        return __children.last
    }

    internal var __childrenCount: Int {
        return self.__children.count
    }

    /// <#Description#>
    public var parent: DatabaseReference? {
        var parent = self
        if parent.__children.isEmpty {
            return nil
        } else {
            parent.__children.removeLast()
            return parent
        }
    }

    /// <#Description#>
    public var root: DatabaseReference {
        var root = self
        root.__children.removeAll()
        return root
    }

    /// <#Description#>
    ///
    /// - Parameter database: <#database description#>
    public init(_ database: Database) {
        self.database = database
    }

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - database: <#database description#>
    ///   - file: <#file description#>
    ///   - design: <#design description#>
    public init(_ database: Database, file: String?, design: String?) {
        self.database = database
        self.__file = file
        self.__design = design
    }

    internal init(ref: DatabaseReference) {
        self.database = ref.database
        self.__file = ref.__file
        self.__design = ref.__design
        self.__children = ref.__children
    }

    /// <#Description#>
    ///
    /// - Parameter children: <#children description#>
    public subscript(_ children: JSONSubscriptType...) -> DatabaseReference {
        mutating get {
            self.__children.append(contentsOf: children)
            return self
        }
    }

    /// <#Description#>
    ///
    /// - Parameter children: <#children description#>
    /// - Returns: <#return value description#>
    public mutating func children(_ children: JSONSubscriptType...) -> DatabaseReference {
        self.__children.append(contentsOf: children)
        return self
    }

    /// <#Description#>
    ///
    /// - Parameter aFile: <#aFile description#>
    /// - Returns: <#return value description#>
    public mutating func file(_ aFile: String) -> DatabaseReference {
        self.__file = aFile
        return self
    }

}

extension DatabaseReference: Hashable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: DatabaseReference, rhs: DatabaseReference) -> Bool {
        return lhs.__children == rhs.__children &&
            lhs.database == rhs.database &&
            lhs.__file == rhs.__file &&
            lhs.__design == rhs.__design
    }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int {
        return self.__file?.hashValue ?? self.database.hashValue
    }

}

extension DatabaseReference {

    internal /* @testable */ func create(
        for object: DatabaseObject,
        with callback: (JSON?, Error?
        ) -> Void)
    {
        do {
            let scheme = try object.scheme()
            callback(DatabaseObjectUtil.DBObjectJSON(from: scheme), nil)
        } catch {
            callback(nil, error)
        }
    }

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - object: <#object description#>
    ///   - callback: <#callback description#>
    public func create(_ object: DatabaseObject, callback: (DatabaseObject?, Error?) -> Void) {
        if !self.__children.isEmpty {
            Log.info("The children will be ignored when creating a new document for the object: \(object)")
        } else {
            callback(object, nil)
        }
    }
}

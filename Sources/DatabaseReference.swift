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
//import MiniPromiseKit

public struct DBSnapshot {

    public var id: String

    public var revision: String

    public var json: JSON

}

private extension Database {

    func exists() -> Promise<Bool> {
        let promise = Promise<Bool> { fullfill, reject in
            self.exists { (error) in
                if let error = error {
                    reject(error)
                } else {
                    fullfill(true)
                }
            }
        }

        return promise
    }
}

extension RequestManager {

    fileprivate func create(for json: JSON, in database: Database) -> Promise<DBSnapshot> {
        return Promise { fullfill, reject in
            self.createObject(for: json, in: database) { (id, rev, json, error) in
                if let error = error {
                    reject(error)
                } else {
                    let snapshot = DBSnapshot(id: id!, revision: rev!, json: json!)
                    fullfill(snapshot)
                }
            }
        }
    }
}

/** */
public struct DatabaseReference {

    // MARK: Properties

    internal var __file: String

    internal var __design: String?

    internal var database: Database

    internal var __children: [JSONSubscriptType] = []

    internal var __child: JSONSubscriptType? {
        return __children.last
    }

    internal var __childrenCount: Int {
        return self.__children.count
    }

    fileprivate var kQueue: DispatchQueue {
        return DispatchQueue(
            label: "database_reference",
            qos: .userInitiated,
            attributes: .concurrent
        )
    }

    // MARK: Init

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - database: <#database description#>
    ///   - file: <#file description#>
    ///   - design: <#design description#>
    public init(_ database: Database, file: String) {
        self.database = database
        self.__file = file
    }

    internal init(ref: DatabaseReference) {
        self.database = ref.database
        self.__file = ref.__file
        self.__design = ref.__design
        self.__children = ref.__children
    }

    public init(_ database: Database, file: String, children: [JSONSubscriptType]) {
        self.database = database
        self.__file = file
        self.__children = children
    }

}

// MARK: - <#Description#>
extension DatabaseReference {

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

}

// MARK: - <#Description#>
extension DatabaseReference {

    /// <#Description#>
    ///
    /// - Parameter children: <#children description#>
    public subscript(children: JSONSubscriptType...) -> DatabaseReference {
        mutating get {
            self.__children.append(contentsOf: children)
            return self
        }
    }

    /// <#Description#>
    ///
    /// - Parameter child: <#child description#>
    public subscript(_ child: JSONSubscriptType) -> DatabaseReference {
        mutating get {
            return self.child(child)
        }
    }

    /// <#Description#>
    ///
    /// - Parameter children: <#children description#>
    /// - Returns: <#return value description#>
    public mutating func children(_ children: JSONSubscriptType...) -> DatabaseReference {
        self.__children.append(contentsOf: children)
        return withUnsafeMutablePointer(to: &self) { (pointer) -> DatabaseReference in
            return pointer.pointee
        }
    }

    /// <#Description#>
    ///
    /// - Parameter aChild: <#aChild description#>
    /// - Returns: <#return value description#>
    public mutating func child(_ aChild: JSONSubscriptType) -> DatabaseReference {
        self.__children.append(aChild)
        return withUnsafeMutablePointer(to: &self) { (pointer) -> DatabaseReference in
            return pointer.pointee
        }
    }

}

// MARK: - Hashable
extension DatabaseReference: Hashable, CustomStringConvertible {

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
        return self.__file.hashValue
    }

    /// A textual representation of this instance.
    ///
    /// Instead of accessing this property directly, convert an instance of any
    /// type to a string by using the `String(describing:)` initializer. For
    /// example:
    ///
    ///     struct Point: CustomStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var description: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(describing: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `description` property.
    public var description: String {
        var `internal`: String = "database: \(self.database), id: \(self.__file)"
        if !self.__children.isEmpty {
            `internal` += ", children \(self.__children)"
        }

        return "DatabaseReference { \(`internal`) }"
    }

}

// MARK: - Deleting Document
extension DatabaseReference {

    /// <#Description#>
    ///
    /// - Parameter callback: <#callback description#>
    public func delete(callback: @escaping (Error?) -> Void) {
        self.database.requestManager.delete(self.__file, in: self.database, callback: callback)
    }

    public func retrive(callback: @escaping (DBSnapshot?, Error?) -> Void) {
        self.database
            .requestManager
            .get_retieveDocument(self.__file, in: self.database) { (id, rev, document, error) in
                if let error = error {
                    callback(nil, error)
                } else {
                    let document_json: JSON
                    if self.__children.isEmpty {
                        document_json = document!
                    } else {
                        document_json = document![self.__children]
                    }

                    if let error = document_json.error {
                        callback(nil, error)
                    } else {
                        let snapshot = DBSnapshot(id: id!, revision: rev!, json: document_json)
                        callback(snapshot, nil)
                    }
                }
        }
    }
}

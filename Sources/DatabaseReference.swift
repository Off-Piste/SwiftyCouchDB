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
import MiniPromiseKit

public struct DBSnapshot {

    var id: String

    var revision: String

    var json: JSON

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

    internal var __file: String?

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

// MARK: - <#Hashable#>
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

// MARK: - Deleting Document
extension DatabaseReference {

    /// <#Description#>
    ///
    /// - Parameter callback: <#callback description#>
    public func delete(callback: @escaping (Error?) -> Void) {
        if let aFile = self.__file {
            self.database.requestManager.delete(aFile, in: self.database, callback: callback)
        } else {
            let error = SwiftError("The file is not set, cannot delete nothing", -401)
            callback(error)
        }
    }

    public func delete<Object: DatabaseObject>(_ object: Object, callback: @escaping (Error?) -> Void) {
        do {
            let scheme = try object.scheme()

            if let aFile = self.__file, let id = scheme.id.value as? String {
                if aFile != id {
                    let message = "This reference is set for [\(aFile)], " +
                                  "but the id of the object is [\(id)] " +
                                  "if you are deleting a document please use " +
                                  "`database.reference(for:)`"

                    let error = SwiftError(message, -200)
                    callback(error)
                } else {
                     self.database.requestManager.delete(id, in: self.database, callback: callback)
                }
            } else {
                let error = SwiftError("The file is not set, cannot delete nothing", -401)
                callback(error)
            }
        } catch {
            callback(error)
        }
    }

}

// MARK: - Creating Documents
extension DatabaseReference {

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - object: <#object description#>
    ///   - callback: <#callback description#>
    public func create(
        _ object: DatabaseObject,
        callback: @escaping (DatabaseObject?, Error?) -> Void
        )
    {
        preCreateCheck(object)

        self.create(for: object) { (_, error) in
            if let error = error {
                callback(nil, error)
            } else {
                callback(object, nil)
            }
        }
    }

    public func create(_ json: JSON, callback: @escaping (DBSnapshot?, Error?) -> Void) {
        self.preCreateCheck(json)

        do {
            try validateJSONForCouchDB(json)
            self.database.requestManager
                .create(for: json, in: self.database)
                .then(on: kQueue, execute: { (snapshot) -> Void in callback(snapshot, nil) })
                .catch(on: kQueue, execute: { (error) in callback(nil, error) })
        } catch {
            callback(nil, error)
        }
    }

    // MARK: Testing

    /* @testable */ internal func create(
        for object: DatabaseObject,
        with callback: @escaping (DBSnapshot?, Error?) -> Void
        )
    {
        do {
            // 1. Validate the Object
            try validateObjectForCouchDB(object)

            // 2. Check is the db exists
            self.database.exists().then(on: kQueue, execute: { _ -> Promise<DBSnapshot> in
                let scheme = try object.scheme()
                let json = DatabaseObjectUtil.DBObjectJSON(from: scheme)
                try self.validateSchemeForCouchDB(scheme)

                // 3. Create the Object in the database
                return self.database.requestManager.create(for: json, in: self.database)
            }).then(on: kQueue, execute: { (snapshot) -> Void in
                callback(snapshot, nil)
            }).catch(on: kQueue) {
                callback(nil, $0)
            }
        } catch {
            callback(nil, error)
        }
    }

    // MARK: Checks

    private func preCreateCheck(_ object: Any) {
        if !self.__children.isEmpty {
            Log.info("The children will be ignored when creating a new document for the object: \(object)")
        }
    }

    private func validateObjectForCouchDB(_ object: DatabaseObject) throws {
        if let db = object.database {
            if db != self.database {
                throw SwiftError("Databases for [\(object)] are not equal", -100)
            } else {
                return
            }
        } else {
            do {
                _ = try Database(object.className.lowercased())
                throw SwiftError("Unknown Error", -404)
            } catch {
                throw error
            }
        }
    }

    private func validateSchemeForCouchDB(_ scheme: DatabaseObjectScheme) throws {
        if let aFile = self.__file, let id = scheme.id.value as? String, aFile != id {
            let message = "This reference is set for [\(aFile)], " +
                          "but the id of the object is [\(id)] " +
                          "if you are creating a document please use " +
                          "`database.reference` for a clean reference"

            throw SwiftError(message, -200)
        }
    }

    private func validateJSONForCouchDB(_ json: JSON) throws {
        if let id = json["_id"].string, let aFile = self.__file, id != aFile {
            let message = "This reference is set for [\(aFile)], " +
                          "but the id of the object is [\(id)] " +
                          "if you are creating a document please use " +
                          "`database.reference` for a clean reference"

            throw SwiftError(message, -200)
        }

        if let id = json["id"].string, let aFile = self.__file, id != aFile {
            let message = "This reference is set for [\(aFile)], " +
                          "but the id of the object is [\(id)] " +
                          "if you are creating a document please use " +
                          "`database.reference` for a clean reference"

            throw SwiftError(message, -200)
        }
    }
}

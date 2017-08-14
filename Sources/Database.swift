//
//  Database.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 08.08.17.
//
//

import Foundation
import MiniPromiseKit
import SwiftyJSON
import LoggerAPI

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

private extension Array where Element == DatabaseObject {

    func removingInvalidObjects(in db: Database) -> [Element] {
        var validObject: [Element] = []

        for object in self {
            do {
                try validateObjectForCouchDB(object, db)
                validObject.append(object)
                continue
            } catch {
                Log.error(error.localizedDescription)
            }
        }

        return validObject
    }

    private func validateObjectForCouchDB(_ object: DatabaseObject, _ database: Database) throws {
        if let db = object.database {
            if db != database {
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
}

class Regex {

    var string: String

    init(_ string: String) {
        self.string = string
    }

    func matches(_ regex: String) -> Bool {
        return (self.string as NSString)
            .range(of: regex, options: .regularExpression)
            .location != NSNotFound
    }

}

/**
 Database Manages the creation and deletion of the databases inside couchdb
 */
public class Database {

    // MARK: Properties

    /// The name of the database you are referencing
    public var name: String

    /// The `Request Manager` for the database, this will power the network calls
    internal var requestManager: RequestManager

    /// The `DatabaseReference` for the current database
    ///
    /// - Note: Will soon be changed to internal so users will have to use
    ///         `reference(for:)`
    public lazy var reference: DatabaseReference = DatabaseReference(self)

    // MARK: Reference

    /// The `DatabaseReference` for a database file/document.
    ///
    /// This is the gateway to modify and delete selected files,
    /// and retrive objects
    ///
    /// - Parameter file: The object id
    /// - Returns: The `DatabaseReference` for a database file/document
    public func reference(for file: String) -> DatabaseReference {
        return self.reference.file(file)
    }

    /// The `DatabaseReference` for a database file/document.
    ///
    /// This is the gateway to modify and delete selected files,
    /// and retrive objects
    ///
    /// - Parameter object: The object you are wishing to reference
    /// - Returns: The Database reference for the said object
    /// - Throws: An error for an invalid object
    public func reference(for object: DatabaseObject) throws -> DatabaseReference {
        let scheme = try object.scheme()

        guard let id = scheme.id.value as? String else {
            throw SwiftError("Invalid Object: \(object)", -400)
        }

        return self.reference(for: id)
    }

    /// The `DatabaseReference` for a database file/document.
    ///
    /// This is the gateway to modify and delete selected files,
    /// and retrive objects
    ///
    /// - note: If the object produces an invalid scheme
    ///         or the id is not a string, the closure will
    ///         not be called
    ///
    /// - Parameters:
    ///   - object: The object you are wishing to reference
    ///   - callback: The Database reference for the said object
    public func reference(for object: DatabaseObject, callback: (DatabaseReference) -> Void) {
        do {
            let ref = try self.reference(for: object)
            callback(ref)
        } catch {
            Log.error("[Invalid Reference] error: \(error.localizedDescription)")
        }
    }

    // MARK: Initializers

    /// <#Description#>
    ///
    /// - Parameter name: <#name description#>
    /// - Throws: <#throws value description#>
    public init(_ name: String) throws {
        if !Regex(name).matches("^[a-z0-9_$,+/]+$") {
            let reqDBName = "Note that only lowercase characters (a-z), " +
                            "digits (0-9), or any of the characters _, $, " +
                            "(, ), +, -, and / are allowed."

            throw SwiftError("Invalid Database Name, \(reqDBName) ", -200)
        }

        guard let cp = Utils.connectionProperties else {
            throw Database.Error.nilConnectionProperties
        }

        let core = CouchDBCore(connectionProperties: cp)
        let rm = RequestManager(_core: core)

        self.name = name
        self.requestManager = rm
    }

    /// <#Description#>
    ///
    /// - Parameter database: <#database description#>
    /// - Throws: <#throws value description#>
    public convenience init<D: Database>(database: @autoclosure () throws -> D) throws {
        try self.init(database: { () -> D in try database() })
    }

    /// <#Description#>
    ///
    /// - Parameter database: <#database description#>
    /// - Throws: <#throws value description#>
    public init<D: Database>(database: (() throws -> D)) throws /* rethrows */ {
        do {
            let db = try database()
            self.name = db.name
            self.requestManager = db.requestManager
        } catch {
            throw error
        }
    }

    // MARK: CouchDB API Requests

    /// <#Description#>
    ///
    /// - Parameter callback: <#callback description#>
    public static func allDatabases(callback: @escaping ([Database], Swift.Error?) -> Void) {
        guard let cp = Utils.connectionProperties else {
            callback([], Database.Error.nilConnectionProperties)
            return
        }

        let core = CouchDBCore(connectionProperties: cp)
        let rm = RequestManager(_core: core)

        rm.allDatabases { (json, error) in
            if let error = error {
                callback([], error)
            } else {
                if let jsonArr = json!.arrayObject {
                    let dbArr = jsonArr.map { try? Database("\($0)") }.flatMap { $0 }
                    callback(dbArr, nil)
                } else {
                    callback([], Database.Error.invalidJSON)
                }
            }

        }
    }

    /// Checks to see if the database exists
    ///
    /// These methods use the [CouchDB API](http://docs.couchdb.org/en/2.1.0/intro/api.html)
    /// calls to create your database, like so:
    ///
    /// ```bash
    /// curl -X HEAD 127.0.0.1:5984/database_name
    /// ```
    ///
    /// - Parameter callback: An error if the database does not exist
    public func exists(callback: @escaping (Swift.Error?) -> Void) {
        self.requestManager.exists(self, callback: callback)
    }

    // MARK: Creating Database

    /// Create a new empty Database with `Database().name`
    ///
    /// These methods use the [CouchDB API](http://docs.couchdb.org/en/2.1.0/intro/api.html) 
    /// calls to create your database, like so:
    ///
    /// ```bash
    /// curl -X PUT 127.0.0.1:5984/database_name
    /// ```
    ///
    /// - Parameter callback: The current database and an error if the call fails
    public func create(callback: @escaping (Database, Swift.Error?) -> Void) {
        self.requestManager.create(self) { callback(self, $0) }
    }

    /// Create a new Database with an document inside
    ///
    /// This is cleaner than calling `.create(callback:)` 
    /// and then `.add(_:callback:)`
    ///
    /// - Note: Design views are subclasses of Database object
    ///         so can be used here.
    ///
    /// - Warning: Structs cannot be subclasses of `DatabaseObject`,
    ///            so for them **until** *Swift 4.0* is compatable with
    ///            us please use the JSON create method
    ///
    /// - Parameters:
    ///   - object: The object to be added upon database creation
    ///   - callback: The current database and an error if the call fails
    public func create(with object: DatabaseObject, callback: @escaping (Database, Swift.Error?) -> Void) {
        do {
            try self.validateObjectForCouchDB(object)

            self.create { (database, error) in
                if error != nil { callback(database, error); return }
                self.add(object, callback: callback)
            }
        } catch {
            callback(self, error)
        }
    }

    /// Create a new Database with an document inside
    ///
    /// This is cleaner than calling `.create(callback:)`
    /// and then `.add(_:callback:)`
    ///
    /// - Note: Design views are subclasses of Database object
    ///         so should be used for the `DatabaseObject` call.
    ///
    /// - Parameters:
    ///   - json: The `JSON` of the object to be added, must be
    ///           a dictionary type
    ///   - callback: The current database and an error if the call fails
    public func create(with json: JSON, callback: @escaping (Database, Swift.Error?) -> Void) {
        if json.type != .dictionary { callback(self, SwiftError("", -0)); return }
        self.requestManager.create(for: json, in: self).then(on: kQueue) { _ -> Void in
            callback(self, nil)
        }.catch(on: kQueue) {
            callback(self, $0)
        }
    }

    // MARK: Adding Objects

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - object: <#object description#>
    ///   - callback: <#callback description#>
    public func add(_ object: DatabaseObject, callback: @escaping (Database, Swift.Error?) -> Void) {
        do {
            try self.validateObjectForCouchDB(object)

            firstly { () -> Promise<DBSnapshot> in
                let scheme = try object.scheme()
                let json = DatabaseObjectUtil.DBObjectJSON(from: scheme)

                return self.requestManager.create(for: json, in: self)
            }.then(on: self.kQueue, execute: { (_) -> Void in
                callback(self, nil)
            }).catch(on: self.kQueue, execute: { (error) in
                callback(self, error)
            })
        } catch {
             callback(self, error)
        }
    }

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - objects: <#objects description#>
    ///   - callback: <#callback description#>
    public func add(_ objects: [DatabaseObject], callback: @escaping (Swift.Error?) -> Void) {
        if objects.isEmpty { callback(SwiftError("Cannot add empty array", -100)); return }
        let count = objects.count

        var index = 0
        for object in objects {
            self.add(object, callback: { (_, error) in
                if error != nil { callback(error); return }

                index += 1
                if count == index { callback(error); return }
            })
        }
    }

    /// - warning: This produces some strange results, will see if its how
    ///            its meant to do it. For now please use `add(_:callback:)`
    ///
    /// - Parameters:
    ///   - objects: An array of Objects
    ///   - callback:
    public func bulkAdd(_ objects: [DatabaseObject], callback: @escaping (Swift.Error?) -> Void) {
        // 1. if objects are empty, end here
        if objects.isEmpty { callback(SwiftError("Cannot add empty array", -100)); return }

        do {

            // 2. Check for invalid objects and throw if they are, else convert to JSON
            let newObjects = try objects
                .removingInvalidObjects(in: self)
                .map { DatabaseObjectUtil.DBObjectJSON(from: try $0.scheme()) }

            // 3. POST _bulk_docs
            self.requestManager.post(newObjects, in: self, callback: { (_, error) in
                callback(error)
            })
        } catch {
            callback(error)
        }
    }

    // MARK: Deleting Objects

    /// <#Description#>
    ///
    /// - Parameter callback: <#callback description#>
    public func delete(callback: @escaping (Swift.Error?) -> Void) {
        self.requestManager.delete(self, callback: callback)
    }

}

// MARK: - Private
private extension Database {

    var kQueue: DispatchQueue {
        return DispatchQueue(label: "io.offpist", qos: .userInitiated, attributes: .concurrent)
    }

    func validateObjectForCouchDB(_ object: DatabaseObject) throws {
        if let db = object.database {
            if db != self {
                throw SwiftError("Databases for the object to be added [\(object.database!)] and the database making the request [\(self)] are not equal", -100)
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

}

// MARK: - Hashable
extension Database : Hashable, CustomStringConvertible {

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
        return "Database { name: \(self.name) }"
    }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Database, rhs: Database) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of 
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int { return self.name.hashValue ^ 1 }

}

// MARK: - UserDatabase

/**
 UserDatabase works slightly differently.
 */
public class UserDatabase: Database {

    /// <#Description#>
    ///
    /// - Throws: <#throws value description#>
    public convenience init() throws {
        try self.init("_users")
    }

    /// <#Description#>
    ///
    /// - Parameter name: <#name description#>
    /// - Throws: <#throws value description#>
    private override init(_ name: String) throws {
        try super.init(name)
    }

    // MARK: Depreciations

    @available(*, unavailable, message: "Not Needed")
    public override func delete(callback: @escaping (Swift.Error?) -> Void) { fatalError() }

    @available(*, unavailable, message: "Not Needed")
    public override func create(callback: @escaping (Database, Swift.Error?) -> Void) { fatalError() }

    @available(*, unavailable, message: "Not Needed")
    public override func exists(callback: @escaping (Swift.Error?) -> Void) { fatalError() }

    @available(*, unavailable, message: "Not Needed")
    public func add<C: Collection>(
        _ objects: C,
        callback: @escaping (Error?) -> Void
        ) where C.Iterator.Element == DatabaseObject
    {
        fatalError()
    }

    @available(*, unavailable, message: "Not Needed")
    public func add(_ object: DatabaseObject, callback: @escaping (Database, Error?) -> Void) {
        fatalError()
    }
}

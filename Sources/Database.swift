//
//  Database.swift
//  CouchDB
//
//  Created by Harry Wright on 20.10.17.
//  Copyright © 2017 Trolley. All rights reserved.
//

import Cocoa
import SwiftyJSON
import LoggerAPI
@_exported import Alamofire

/// The infomation returned froma GET request on the server.
public struct DatabaseInfo: Codable, CustomStringConvertible {

    /// Set to true if the database compaction routine is operating on this database.
    public var compact_running: Bool

    /// The name of the database.
    public var db_name: String

    /// The version of the physical format used for the data when it is stored on disk.
    public var disk_format_version: Int

    /// A count of the documents in the specified database.
    public var doc_count: Int

    /// Number of deleted documents
    public var doc_del_count: Int

    /// The number of purge operations on the database.
    public var purge_seq: Int

    /// The current number of updates to the database.
    public var update_seq: Int

    /// A textual representation of this instance.
    public var description: String {
        do {
            let str = String(data: try JSONEncoder().encode(self), encoding: .utf8)
            return "DatabaseInfo<\(db_name)>\(str ?? "Invalid JSON")"
        } catch {
            return error.localizedDescription
        }
    }
}

/// <#Description#>
public struct DBDocumentInfo {

    /// <#Description#>
    public var _id: String

    /// <#Description#>
    public var _rev: String

    /// <#Description#>
    public var json: JSON
}

/// Callback for any simple requests where a bool is used
public typealias CouchDBCheckCallback = (Bool, Swift.Error?) -> Void

/// Callback for getting the database info
public typealias CouchDBDatabseInfoCallback = (DatabaseInfo?, Swift.Error?) -> Void

public typealias CouchDBResponse = (DBDocumentInfo?, Swift.Error?) -> Void

/// A `Database` instance represents a CouchDB database
///
/// Database will be using the Database API references found
/// [here](http://docs.couchdb.org/en/2.1.0/api/database/index.html)
///
///
public struct Database {

    // MARK: Properties

    /// The name of the Databae
    public var name: String

    /// The infomation returned froma GET request on the server.
    ///
    /// - Note: Will be nil if the server returns a 404 or if the request
    ///         has not been returned yet.
    public var info: DatabaseInfo?

    /// The DBConfiguration for the server
    public var configuration: DBConfiguration

    /// The request manager to the CouchDB requests
    internal var request: CouchDBRequests

    // MARK: Life Cycle

    /// The method to create a new Database object.
    ///
    /// This is used by any DBObject subclass unless the `database` property is
    /// overwriten.
    ///
    /// - Note:             Passes `DBConfiguration.default`, which can be changed
    ///                     by calling `DBConfiguration.setDefault()`.
    /// - Parameter name:   The database name
    /// - Throws:           This will either throw an `.invalidDatabase` error if the
    ///                     database name is invalid or a `.couchNotRunning`
    ///                     if couchdb is set to run locally but is not running.
    public init(_ name: String) throws {
        try self.init(name, configuration: .default)
    }

    /// Method to create a new Database object with a given DBConfiguration
    ///
    /// - Parameters:
    ///   - name:           The database name
    ///   - configuration:  The configuration for the database
    /// - Throws:           This will either throw an `.invalidDatabase` error if the
    ///                     database name is invalid or a `.couchNotRunning`
    ///                     if couchdb is set to run locally but is not running.
    public init(_ name: String, configuration: DBConfiguration) throws {
        // Check the
        let patern = "^[a-z][a-z0-9_$()+/-]*$"
        if !name.doesMatch(patern) {
            let reqDBName = "Note that only lowercase characters (a-z), " +
                            "digits (0-9), or any of the characters _, $, " +
                            "(, ), +, -, and / are allowed."
            throw createDBError(.invalidDatabase, reason: "Invalid Database Name, \(reqDBName)")
        }

        // Take the first is there are more matches so we won't hit any errors
        self.name = name.matches(patern).first!
        self.configuration = configuration
        self.request = CouchDBRequests(name: name, configuartion: configuration)

        try self.commonInit()
    }

    /// Method to create a Database with an URL.
    ///
    /// Passing `'http://127.0.0.1:5984/_users'` will create a database with:
    /// ```
    /// var config = DBConfiguration(host: 127.0.0.1, port: 5984, secure: false)
    /// var db_name = String("_users")
    /// try Database(db_name, configuration: config)
    /// ```
    ///
    /// - Parameter url: The url for your CouchDB Database
    /// - Throws: An invalid URL if the URL is invalid.
    public init(url: URLConvertible) throws {
        let realURL = try url.asURL()
        let (name, config) = try handleURL(realURL)
        try self.init(name, configuration: config)
    }

    private mutating func commonInit() throws {
//        if configuration.host == "127.0.0.1" {
//            // Using Data(contentsOf: ...) as CouchDB is running local so will be > 21ms
//            let base_url: URL = URL(string: "\(self.configuration.URL)")!
//
//            // Check if CouchDB is running
//            let couch_db_welcome = try? Data(contentsOf: base_url)
//            if couch_db_welcome == nil {
//                let msg = "CouchDB is not running, please call `couchdb` in your terminal"
//                throw createDBError(.couchNotRunning, reason: msg)
//            }
//
//            // Get Database Infomation
//            do {
//                let data: Data = try Data(contentsOf: base_url.appendingPathComponent(name))
//                self.info = try? JSONDecoder().decode(DatabaseInfo.self, from: data)
//
//                if self.info == nil {
//                    var json = JSON(data: data)
//                    Log.error(json.stringValue)
//                }
//            } catch {
//                Log.info("Could not connect to database")
//                Log.verbose("Could not connect to database, so will assume database has not bee created yet")
//            }
//        } else {
//            // Get Database Infomation
////            self.info(callback: { (new_info, error) in
////                if let new_info = new_info {
////                    DispatchQueue.main.sync { self.info = new_info }
////                }
////                Log.error(error!.localizedDescription)
////            })
//        }

    }
}

extension Database: Hashable, CustomStringConvertible {

    // MARK: Hashable, CustomStringConvertible


    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int {
        return self.name.hashValue
    }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: Database, rhs: Database) -> Bool {
        return lhs.hashValue == rhs.hashValue
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
        return "Database{name=\(self.name)}"
    }

}

extension Database {

    // MARK: /{db} Requests

    /// Method used to check if a Database exists.
    ///
    /// Using this method is the same as calling this with curl:
    ///
    /// ```bash
    /// curl -X HEAD 127.0.0.1:5984/database_name
    /// ```
    ///
    /// - Note:                 For more info on the see
    ///                         [here](http://docs.couchdb.org/en/2.1.0/api/database/common.html#db)
    /// - Parameter callback:   True if the response code is 200 or false if 404.
    ///                         Will only return an error if there is no response
    public func exists(callback: @escaping CouchDBCheckCallback) {
        self.request.database_exists(callback: callback)
    }

    /// PUT /{db}
    ///
    /// - Parameter callback: <#callback description#>
    public func create(callback: @escaping (Database?, Error?) -> Void) {
        self.request.database_create(callback: callback)
    }

    /// HEAD /{db} -> PUT /{db}
    ///
    /// - Parameter callback: <#callback description#>
    public func createIfDoesNotExist(callback: @escaping (Database?, Error?) -> Void) {
        self.exists { (exists, error) in
            // Error code 500 is internal error, so the next request would return the same
            // result, so just return there to save time.
            if error?._code == 500 { callback(nil, error); return }

            // If the server doesn't exist then create the new server
            if !exists { self.create(callback: callback) }
        }
    }

    /// GET /{db}
    ///
    /// - Parameter callback: <#callback description#>
    public func info(callback: @escaping CouchDBDatabseInfoCallback) {
        self.request.database_info { (data, error) in
            if let error = error { callback(nil, error); return }

            do {
                let info = try JSONDecoder().decode(DatabaseInfo.self, from: data!)
                callback(info, nil)
            } catch {
                callback(nil, error)
            }
        }
    }

    /// DELETE /{db}
    ///
    /// - Parameter callback: <#callback description#>
    public func delete(callback: @escaping (Bool, Swift.Error?) -> Void) {
        self.request.database_delete(callback: callback)
    }

    /// POST /{db}
    ///
    /// - Parameters:
    ///   - object: <#object description#>
    ///   - callback: <#callback description#>
    public func add<Object: DBObjectBase>(_ object: Object, callback: @escaping CouchDBResponse) {
        do {
            let data = try Utils.encoder.encode(object)
            self.add(JSON(data: data), callback: callback)
        } catch {
            callback(nil, error)
        }
    }

    /// POST /{db}
    ///
    /// - Parameters:
    ///   - json: <#json description#>
    ///   - callback: <#callback description#>
    public func add(_ json: JSON, callback: @escaping CouchDBResponse) {
        if let error = json.error {
            callback(nil, error)
        } else {
            self.request.database_add(json, callback: callback)

        }
    }

}

extension Database {

    // MARK: /db/_all_docs

    /// GET /{db}/_all_docs
    ///
    /// - Parameter callback: <#callback description#>
    public func allDocs(callback: (JSON?, Error?) -> Void) {
        
    }

    /// POST /{db}/_all_docs
    ///
    /// - Parameters:
    ///   - ids: <#ids description#>
    ///   - callback: <#callback description#>
    public func mutipleDocs(with ids: [String], callback: CouchDBResponse) { }

}

extension Database {

    // MARK: Retriving Objects

    /// Method to retrive an object with the required _id
    ///
    /// - Parameters:
    ///   - type:       The type of DBObject
    ///   - id:         The _id for the Document
    ///   - callback:   (Object?, Swift.Error?) -> Void
    public func object<Object: DBObject>(
        _ type: Object.Type,
        withID id: String,
        callback: @escaping (Object?, Swift.Error?) -> Void
        )
    {
        self.objects(type) { (objects, error) in
            if let error = error {
                callback(nil, error)
            } else {
                let filteredObject = objects?.filter { $0.id == id }
                if let object = filteredObject?.first {
                    callback(object, nil)
                } else {
                    let msg = "Objects \(objects!) does not contain an object with the id: \(id)"
                    let err = createDBError(.invalidRequest, reason: msg)
                    callback(nil, err)
                }
            }
        }
    }

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - predicateFormat: <#predicateFormat description#>
    ///   - args: <#args description#>
    ///   - callback: <#callback description#>
    public func objects<Object: DBObject>(
        _ type: Object.Type,
        where predicateFormat: String,
        args: Any...,
        callback: ([Object]?, Swift.Error?) -> Void
        )
    {
        let predicate = NSPredicate(format: predicateFormat, argumentArray: args)
        self.objects(type, where: predicate, callback: callback)
    }

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - predicate: <#predicate description#>
    ///   - callback: <#callback description#>
    public func objects<Object: DBObject>(
        _ type: Object.Type,
        where predicate: NSPredicate,
        callback: ([Object]?, Swift.Error?) -> Void
        )
    {
        self.objects(type) { (objects, error) in
            if let error = error {
                callback(nil, error)
            } else {
                callback((objects! as NSArray).filtered(using: predicate) as? [Object], nil)
            }
        }
    }


    /// Method to get an array of Objects from the database.
    ///
    /// - Note: Using the class passed in `type:` we will create an array of
    ///         those objects, ignoring ones that are not of that type so if your
    ///         array contains many different objects they will not be parsed
    /// - Parameters:
    ///   - type: The
    ///   - callback: <#callback description#>
    public func objects<Object: DBObject>(
        _ type: Object.Type,
        callback: ([Object]?, Swift.Error?) -> Void
        )
    {
        do { try validateRequest(type) } catch { callback(nil, error) }
    }

    private func validateRequest<Object: DBObject>(_ type: Object.Type) throws {
        guard let objectDB = type.database else {
            let msg = "The object type \(type) has an invalid database so we cannot connect"
            throw createDBError(.invalidDatabase, reason: msg)
        }

        if objectDB != self {
            let msg = "The object has a differring database [\(objectDB)] to the one being used [\(self)]"
            throw createDBError(.incompatableDatabase, reason: msg)
        }
    }
}

func handleURL(_ url: URL) throws -> (String, DBConfiguration) {
    guard let urlComps = URLComponents(url: url, resolvingAgainstBaseURL: false),
        let scheme = urlComps.scheme,
        let host = urlComps.host
        else {
            throw createDBError(.invalidURL, reason: "Invalid URL: \(url)")
    }

    let secure: Bool = scheme == "https"
    let port: Int16 = Int16(urlComps.port ?? 0000)
    let username: String? = urlComps.user
    let password: String? = url.password

    let paths = urlComps.path.components(separatedBy: "/")
    guard let dbName = paths.last else {
        throw createDBError(40, reason: "Could not retreive Database name from: \(url)")
    }

    let config = DBConfiguration(host: host, port: port, secured: secure, username: username, password: password)
    return (dbName, config)
}

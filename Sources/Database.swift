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

public enum DBQueryOption {
    case attachments(Bool)
    case att_encoding_info(Bool)
    case atts_since(NSArray)
    case conflicts(Bool)
    case deleted_conflicts(Bool)
    case latest(Bool)
    case local_seq(Bool)
    case meta(Bool)
    case open_revs(NSArray)
    case rev(String)
    case revs(Bool)
    case revs_info(Bool)
}

extension Array where Element == DBQueryOption {
    func toParameters() -> Parameters {
        var parameters: Parameters = [:]

        for option in self {
            switch option {
            case .attachments(let attachments):
                parameters.updateValue(attachments, forKey: "attachments")
            case .att_encoding_info(let info):
                parameters.updateValue(info, forKey: "att_encoding_info")
            case .atts_since(let array):
                parameters.updateValue(array, forKey: "atts_since")
            case .conflicts(let conflicts):
                parameters.updateValue(conflicts, forKey: "conflicts")
            case .deleted_conflicts(let deleted_conflicts):
                parameters.updateValue(deleted_conflicts, forKey: "deleted_conflicts")
            case .latest(let latest):
                parameters.updateValue(latest, forKey: "latest")
            case .local_seq(let local_seq):
                parameters.updateValue(local_seq, forKey: "local_seq")
            case .meta(let meta):
                parameters.updateValue(meta, forKey: "meta")
            case .open_revs(let open_revs):
                parameters.updateValue(open_revs, forKey: "open_revs")
            case .rev(let revision):
                parameters.updateValue(revision, forKey: "rev")
            case .revs(let revisions):
                parameters.updateValue(revisions, forKey: "revs")
            case .revs_info(let rev_info):
                parameters.updateValue(rev_info, forKey: "rev_info")
            }
        }

        return parameters
    }
}

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
    /// - Throws:           An `.invalidDatabase` error if the database
    ///                     name is invalid.
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
}

extension Database: Hashable, CustomStringConvertible {

    // MARK: Hashable, Equatable, CustomStringConvertible.


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

    /// Method to get the information about the specified database.
    ///
    /// Using this method is the same as calling this with curl:
    ///
    /// ```bash
    /// curl -X GET 127.0.0.1:5984/database_name
    /// ```
    /// - Note:                 For more info on the see
    ///                         [here](http://docs.couchdb.org/en/2.1.0/api/database/common.html#db)
    /// - Parameter callback:   The database info if the response is 200 or an
    ///                         error if the response was 404
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

    /// Method to creates a new database.
    ///
    ///
    /// Using this method is the same as calling this with curl:
    ///
    /// ```bash
    /// curl -X PUT 127.0.0.1:5984/database_name
    /// ```
    ///
    /// - Warning:              Error: 412, is called if the Databse already exists
    /// - Note:                 The database has already been validated so will never
    ///                         his an error code 400
    /// - Parameter callback:   Returns a Database if the request returns a 200 or an
    ///                         error if code is 401 or 412
    public func create(callback: @escaping (Database?, Error?) -> Void) {
        self.request.database_create(callback: callback)
    }

    /// Method to deletes the specified database, and all the documents
    /// and attachments contained within it.
    ///
    /// Using this method is the same as calling this with curl:
    ///
    /// ```bash
    /// curl -X DELETE 127.0.0.1:5984/database_name
    /// ```
    ///
    /// - Parameter callback:   Retuns True if the Database has been deleted,
    ///                         or false if not, with an accompanying error
    public func delete(callback: @escaping (Bool, Swift.Error?) -> Void) {
        self.request.database_delete(callback: callback)
    }

    /// Creates a new document in the specified database,
    /// using the supplied DBObject.
    ///
    /// Using this method is the same as calling this with curl:
    ///
    /// ```bash
    /// curl -X POST -H 'Content-Type: application/json' -d '{"_id":"abc"}' 127.0.0.1:5984/database_name
    /// ```
    ///
    /// - Note:         The object uses Codable so make sure you override
    ///                 the DBObjects's methods and call super or the object
    ///                 will be sent with just an "_id"
    /// - Parameters:
    ///   - object:     The object to be added to the Database
    ///   - callback:   The document infomation if the request was sucessful
    ///                 or the error that has occured
    public func add<Object: DBObjectBase>(_ object: Object, callback: @escaping CouchDBResponse) {
        do {
            let data = try Utils.encoder.encode(object)
            self.add(JSON(data: data), callback: callback)
        } catch {
            callback(nil, error)
        }
    }

    /// Creates a new document in the specified database,
    /// using the supplied JSON document structure.
    ///
    /// If the JSON structure includes the "_id" field, then the
    /// document will be created with the specified document ID.
    ///
    /// If the "_id" field is not specified, a new unique ID will be generated,
    /// following whatever UUID algorithm is configured for that server.
    ///
    /// Using this method is the same as calling this with curl:
    ///
    /// ```bash
    /// curl -X POST -H 'Content-Type: application/json' -d '{"_id":"abc"}' 127.0.0.1:5984/database_name
    /// ```
    ///
    /// - Parameters:
    ///   - json:       The JSON document to be added
    ///   - callback:   The document infomation if the request was sucessful
    ///                 or the error that has occured
    public func add(_ json: JSON, callback: @escaping CouchDBResponse) {
        if let error = json.error {
            callback(nil, error)
        } else {
            self.request.database_add(json, callback: callback)

        }
    }

    // TODO: Do we really need this??
    internal func createIfDoesNotExist(callback: @escaping (Database?, Error?) -> Void) {
        self.exists { (exists, error) in
            // Error code 500 is internal error, so the next request would return the same
            // result, so just return there to save time.
            if error?._code == 500 { callback(nil, error); return }

            // If the server doesn't exist then create the new server
            if !exists { self.create(callback: callback) }
        }
    }

}

// TODO: PUT ?? Do we need PUT /{db}/{docid} or keep POST /{db}
// TODO: DELETE

extension Database {

    // MARK: /{db}/{docid}
    // These will be for people using JSON and not DBObject subclasses.

    /// Method to get a document by the specified `docid` from the specified db.
    ///
    /// Using this method is the same as calling this with curl:
    ///
    /// ```bash
    /// curl -X GET 127.0.0.1:5984/database_name/id
    /// ```
    ///
    /// - Parameters:
    ///   - id:         The ID of the Object
    ///   - options:    Any query parameters for the request
    ///   - callback:   The document info for the document or an error
    /// - Note:         Unless you pass [.rev(...)] for options you will get the
    ///                 latest revision of the document will always be returned.
    public func retrieve(_ id: String, options: [DBQueryOption]? = nil, callback: @escaping (DBDocumentInfo?, Error?) -> Void) {
        self.request.database_retrieve(id, parameters: options?.toParameters(), callback: callback)
    }

    /// Method to update a document with new JSON
    ///
    /// - Note:         If you are using a DBObject, please use
    ///                 `DBObject().update(callback:)`
    /// - Parameters:
    ///   - id:         The ID for the Document
    ///   - json:       The new JSON for the document
    ///   - callback:   The changes that have occured to the document
    public func update(_ id: String, with json: JSON, callback: @escaping (DBObjectChange) -> Void) {
        // 1. Retrieve the old object
        self.retrieve(id) { (info, error) in
            if let info = info {
                // 2. Get the oldProperties & revision for the retrieved object
                let rev = info._rev
                let oldProperties = info.json.toProperties

                // 3. Set the new Properties
                let newProperties = json.toProperties

                // 4. Update the documents
                self.request.doc_update(id, rev: rev, json: json) { (info, error) in
                    if let error = error {
                        callback(.error(error))
                    } else {
                        // 5. Check for changes and pass changes back
                        let changes = checkChanges(from: oldProperties, to: newProperties)
                        callback(.changes(changes))
                    }
                }
            } else {
                // If error 404, safe to assume is deleted
                if let afError = error as? AFError, let responseCode = afError.responseCode, responseCode == 404 {
                    callback(.deleted)
                } else {
                    callback(.error(error!))
                }
            }
        }
    }


    public func deleteObject(_ id: String, callback: @escaping (Bool, Error?) -> Void) {
        self.request.doc_delete(id, callback: callback)
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

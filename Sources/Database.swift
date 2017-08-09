//
//  Database.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 08.08.17.
//
//

import Foundation

/**
 Database Manages the creation and deletion of the databases inside couchdb
 */
public class Database {

    /// <#Description#>
    public var name: String

    /// <#Description#>
    fileprivate var requestManager: RequestManager

    public lazy var reference: DatabaseReference = DatabaseReference(self)

    public func reference(for file: String) -> DatabaseReference {
        return self.reference.file(file)
    }

    /// <#Description#>
    ///
    /// - Parameter name: <#name description#>
    /// - Throws: <#throws value description#>
    public init(_ name: String) throws {
        guard let cp = Utils.connectionProperties else {
            throw Database.Error.nilConnectionProperties
        }

        let core = CouchDBCore(connectionProperties: cp)
        let rm = RequestManager(_core: core)

        self.name = name
        self.requestManager = rm
    }

    // FIXME: Init fails in tests
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

    /// <#Description#>
    ///
    /// - Parameter callback: <#callback description#>
    public func exists(callback: @escaping (Swift.Error?) -> Void) {
        self.requestManager.exists(self, callback: callback)
    }

    /// <#Description#>
    ///
    /// - Parameter callback: <#callback description#>
    public func create(callback: @escaping (Database, Swift.Error?) -> Void) {
        self.requestManager.create(self) { callback(self, $0) }
    }

    /// <#Description#>
    ///
    /// - Parameter callback: <#callback description#>
    public func delete(callback: @escaping (Swift.Error?) -> Void) {
        self.requestManager.delete(self, callback: callback)
    }

}

extension Database : Hashable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Database, rhs: Database) -> Bool {
        return lhs.name == rhs.name
    }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of 
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int { return self.name.hashValue }

}

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

    // MARK: - Depreciations

    @available(*, unavailable, message: "Not Needed")
    public override func delete(callback: @escaping (Swift.Error?) -> Void) { fatalError() }

    @available(*, unavailable, message: "Not Needed")
    public override func create(callback: @escaping (Database, Swift.Error?) -> Void) { fatalError() }

    @available(*, unavailable, message: "Not Needed")
    public override func exists(callback: @escaping (Swift.Error?) -> Void) { fatalError() }

}

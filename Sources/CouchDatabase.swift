//
//  CouchDatabase.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 25.07.17.
//
//

import Foundation
import SwiftyJSON
import CouchDB

public typealias CouchReference = DatabaseReference<CouchDatabase>

public struct CouchDatabase : DBManager {

    public var reference: CouchReference {
        return DatabaseReference(db: database, design: design)
    }

    var database: Database

    var design: String?

    var client: CouchDBClient {
        return CouchDBClient(connectionProperties: self.database.connProperties)
    }

    public init(name: String, design: String? = nil) throws {
        guard let cp = ConnectionPropertiesManager.connectionProperties else {
            throw createError("The CouchDB connection properties have not been set", code: -101)
        }

        let db = Database(connProperties: cp, dbName: name)
        self.init(db: db, design: design)
    }

    public init(db: Database, design: String?) {
        self.database = db
        self.design = design
    }
}

extension CouchDatabase {

    func exists(callback: @escaping (Bool, Error?) -> Void) {
        self.client.dbExists(self.database.name, callback: callback)
    }

    func create(callback: @escaping (Error?) -> Void) {
        self.client.createDB(self.database.name) { callback($0.1) }
    }

    func delete(callback: @escaping (Error?) -> Void) {
        self.client.deleteDB(self.database, callback: callback)
    }
}

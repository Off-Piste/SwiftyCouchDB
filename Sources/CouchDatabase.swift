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

struct CouchDatabase : DBManager {

    public var reference: DatabaseReference<CouchDatabase> {
        return DatabaseReference(db: database, design: design)
    }

    var database: Database

    var design: String

    var client: CouchDBClient {
        return CouchDBClient(connectionProperties: self.database.connProperties)
    }

    public init(name: String, design: String) throws {
        guard let cp = ConnectionPropertiesManager.connectionProperties else {
            throw NSError()
        }

        let db = Database(connProperties: cp, dbName: name)
        self.init(db: db, design: design)
    }

    public init(db: Database, design: String) {
        self.database = db
        self.design = design
    }
    
}

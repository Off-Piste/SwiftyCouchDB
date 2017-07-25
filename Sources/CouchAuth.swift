//
//  CouchAuth.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 25.07.17.
//
//

import Foundation
import SwiftyJSON
import CouchDB

struct CouchAuth: DBManager {

    public var reference: DatabaseReference<CouchAuth> {
        return DatabaseReference(db: database, design: design)
    }

    var database: Database

    var design: String

    var client: CouchDBClient

    public init() throws {
        guard let cp = ConnectionPropertiesManager.connectionProperties else {
            throw NSError()
        }

        let client = CouchDBClient(connectionProperties: cp)
        self.init(client: client, design: "user")
    }

    private init(client: CouchDBClient, design: String) {
        self.client = client
        self.database = client.usersDatabase()
        self.design = design
    }
    
}

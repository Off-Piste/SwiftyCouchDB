//
//  DatabaseManager.swift
//  SwiftyCouchCB
//
//  Created by Harry Wright on 24.07.17.
//
//

import Foundation
import CouchDB

public struct DatabaseManager {

    public var reference: DatabaseReference

    // swiftlint:disable opening_brace
    public init(
        connectionProperties cp: ConnectionProperties,
        databaseName: String,
        design: String
        )
    {
        let client: CouchDBClient = CouchDBClient(connectionProperties: cp)
        let db = client.database(databaseName)

        let dbDesign: DatabaseDesign
        if !design.contains("_design/") {
            dbDesign = DatabaseDesign(name: "_design/" + design)
        } else {
            dbDesign = DatabaseDesign(name: design)
        }

        self.reference = DatabaseReference(client: client, db: db, design: dbDesign, file: nil)
    }

    public func referenceForFile(_ aFile: String) -> DatabaseReference {
        let file = DatabaseFile(name: aFile)
        return DatabaseReference(
            client: reference.client,
            db: reference.database,
            design: reference.design,
            file: file
        )
    }
}

//
//  CouchDB.swift
//  CouchDB
//
//  Created by Harry Wright on 23.10.17.
//  Copyright © 2017 Trolley. All rights reserved.
//

import Foundation
import SwiftyJSON

public typealias CouchDBServerResponse = (JSON?, Swift.Error?) -> Void

public final class CouchDB {

    /// GET /_active_tasks
    ///
    /// - Parameter callback: <#callback description#>
    public static func activeTasks(callback: CouchDBServerResponse) { }

    /// GET /_all_dbs
    ///
    /// - Parameter callback: <#callback description#>
    public static func allDatabases(callback: CouchDBServerResponse) { }


    /// GET /_db_updates
    ///
    /// - Parameter callback: <#callback description#>
    public static func dbUpdates(callback: CouchDBServerResponse) { }

    /// POST /_restart
    ///
    /// - Parameter callback: <#callback description#>
    public static func restart(callback: CouchDBServerResponse) { }

    /// GET /_stats
    ///
    /// - Parameter callback: <#callback description#>
    public static func stats(callback: CouchDBResponse) { }

    /// GET /_uuids
    ///
    /// - Parameter callback: <#callback description#>
    public static func uuids(callback: CouchDBResponse) { }

}

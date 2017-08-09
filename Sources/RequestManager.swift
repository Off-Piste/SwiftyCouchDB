//
//  RequestManager.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 08.08.17.
//
//

import Foundation
import KituraNet

struct RequestManager {

    var _core: CouchDBCore

    func exists(_ db: Database, callback: @escaping (Swift.Error?) -> Void) {
        let options = CouchDBCore.Utils.prepareRequest(
            for: _core.connectionProperties,
            method: .get,
            path: "/\(HTTP.escape(url: db.name))",
            hasBody: false
        )

        let request = HTTP.request(options) { response in
            if let response = response {
                if response.statusCode == HTTPStatusCode.OK {
                    callback(nil)
                } else {
                    callback(Database.Error.databaseDoesntExist)
                }
            } else {
                callback(Database.Error.internalError)
            }
        }
        request.end()
    }

    func create(_ db: Database, callback: @escaping (Swift.Error?) -> Void) {
        let options = CouchDBCore.Utils.prepareRequest(
            for: _core.connectionProperties,
            method: .put,
            path: "/\(HTTP.escape(url: db.name))",
            hasBody: false
        )

        let request = HTTP.request(options) { (response) in
            guard let response = response else {
                callback(Database.Error.internalError)
                return
            }

            if response.statusCode == .created {
                callback(nil)
            } else {
                if let descOpt = try? response.readString(), let desc = descOpt {
                    callback(Database.Error.couchDBError(desc, code: response.statusCode))
                } else {
                    callback(Database.Error.invalidStatusCode(response.statusCode))
                }
            }
        }
        request.end()
    }

    func delete(_ db: Database, callback: @escaping (Swift.Error?) -> Void) {
        let options = CouchDBCore.Utils.prepareRequest(
            for: _core.connectionProperties,
            method: .delete,
            path:"/\(HTTP.escape(url: db.name))",
            hasBody: false
        )

        let request = HTTP.request(options) { (response) in
            guard let response = response else {
                callback(Database.Error.internalError)
                return
            }

            if response.statusCode != .OK {
                if let descOpt = try? response.readString(), let desc = descOpt {
                    callback(Database.Error.couchDBError(desc, code: response.statusCode))
                } else {
                    callback(Database.Error.invalidStatusCode(response.statusCode))
                }
            } else {
                callback(nil)
            }
        }
        request.end()
    }
}

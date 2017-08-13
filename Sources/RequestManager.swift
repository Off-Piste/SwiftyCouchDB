//
//  RequestManager.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 08.08.17.
//
//

import Foundation
import KituraNet
import SwiftyJSON

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

    typealias DError = Database.Error

    typealias Snapshot = (_ id: String?, _ rev: String?, _ json: JSON?, _ error: SError?) -> Void

    func createObject(
        for json: JSON,
        in db: Database,
        callback: @escaping Snapshot
        )
    {
        if let requestBody = json.rawString() {
            var id: String?
            var doc: JSON?
            var revision: String?
            let escapedName = HTTP.escape(url: db.name)

            let requestOptions = CouchDBCore.Utils.prepareRequest(
                for: _core.connectionProperties,
                method: .post,
                path: "/\(escapedName)",
                hasBody: true
            )

            let req = HTTP.request(requestOptions, callback: { (response) in
                if let response = response {
                    do {
                        doc = try CouchDBCore.Utils.getBodyAsJSON(for: response)
                        id = doc?["id"].string
                        revision = doc?["rev"].string

                        if response.statusCode != .created &&
                            response.statusCode != .accepted {
                            callback(nil, nil, nil, DError.invalidStatusCode(response.statusCode))
                        } else {
                            callback(id, revision, doc, nil)
                        }
                    } catch {
                        callback(nil, nil, nil, error)
                    }
                } else {
                    callback(nil, nil, nil, DError.internalError)
                }
            })
            req.end(requestBody)
        } else {
            callback(nil, nil, nil, DError.invalidJSON)
        }

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

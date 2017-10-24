//
//  CouchDBRequests.swift
//  SwiftyCouchDBPackageDescription
//
//  Created by Harry Wright on 23.10.17.
//

import Foundation
import SwiftyJSON
import KituraNet

private extension ClientResponse {
    func isEqual(to codes: HTTPStatusCode...) -> Bool {
        for code in codes {
            if self.statusCode != code { return false }
        }

        return true
    }
}

struct CouchDBRequestsUtils {

    static func prepareRequest(
        _ connProperties: DBConfiguration,
        method: String,
        path: String,
        hasBody: Bool,
        contentType: String = "application/json"
        ) -> [ClientRequest.Options]
    {
        var requestOptions: [ClientRequest.Options] = []

        if let username = connProperties.username {
            requestOptions.append(.username(username))
        }
        if let password = connProperties.password {
            requestOptions.append(.password(password))
        }

        requestOptions.append(.schema("\(connProperties.HTTPProtocol)://"))
        requestOptions.append(.hostname(connProperties.host))
        requestOptions.append(.port(connProperties.port))
        requestOptions.append(.method(method))
        requestOptions.append(.path(path))

        var headers = [String:String]()
        headers["Accept"] = "application/json"
        if hasBody {
            headers["Content-Type"] = contentType
        }

        requestOptions.append(.headers(headers))
        return requestOptions
    }

    static func getBodyAsJson(_ response: ClientResponse) throws -> JSON {
        var body = Data()
        try response.readAllData(into: &body)
        let json = JSON(data: body)

        return json
    }

    static func getBodyAsData(_ response: ClientResponse) throws -> Data {
        var body = Data()
        try response.readAllData(into: &body)
        return body
    }
}

class CouchDBRequests {

    typealias Utils = CouchDBRequestsUtils

    var database: Database

    init(db: Database) { self.database = db }

}

extension CouchDBRequests {

    public func database_info(callback: @escaping (Data?, Swift.Error?) -> Void) {
        let requestOptions = Utils.prepareRequest(
            self.database.configuration,
            method: "GET",
            path: "/\(HTTP.escape(url: self.database.name))",
            hasBody: false
        )

        let req = HTTP.request(requestOptions) { (response) in
            if let response = response {
                do {
                    var data: Data? = try Utils.getBodyAsData(response)
                    var error: Swift.Error?

                    if response.statusCode != .OK {
                        error = createDBError(response)
                        data = nil
                    }

                    callback(data, error)
                } catch {
                    callback(nil, error)
                }
            } else {
                let error = createDBError(.internalError)
                callback(nil, error)
            }
        }
        req.end()
    }

    public func database_exists(callback: @escaping (Bool, Swift.Error?) -> Void) {
        let requestOptions = Utils.prepareRequest(
            self.database.configuration,
            method: "HEAD",
            path: "/\(HTTP.escape(url: self.database.name))",
            hasBody: false
        )

        let req = HTTP.request(requestOptions) { (response) in
            if let response = response {
                if response.statusCode == .OK { callback(true, nil); return }

                // FIXME: Do we pass the error or not?
                // The error is just 404, "not found", is it
                // really worth passing, when we can just pass
                // the only error worth noting (.internalError)
                callback(false, nil)
            } else {
                let error = createDBError(.internalError)
                callback(false, error)
            }
        }
        req.end()
    }

    public func database_create(callback: @escaping (Database, Swift.Error?) -> Void) {
        let requestOptions = Utils.prepareRequest(
            self.database.configuration,
            method: "PUT",
            path: "/\(HTTP.escape(url: self.database.name))",
            hasBody: false
        )

        let req = HTTP.request(requestOptions) { (response) in
            if let response = response {
                if response.statusCode == .created {
                    callback(self.database, nil)
                } else {
                    let error = createDBError(response)
                    callback(self.database, error)
                }
            } else {
                let error = createDBError(.internalError)
                callback(self.database, error)
            }
        }
        req.end()
    }

    public func database_delete(callback: @escaping (Bool, Swift.Error?) -> Void) {
        let requestOptions = Utils.prepareRequest(
            self.database.configuration,
            method: "DELETE",
            path: "/\(HTTP.escape(url: self.database.name))",
            hasBody: false
        )

        let req = HTTP.request(requestOptions) { (response) in
            if let response = response {
                if response.statusCode == .OK {
                    callback(true, nil)
                } else if response.statusCode == .badRequest || response.statusCode == .notFound {
                    callback(false, nil)
                } else {
                    // 401
                    let error = createDBError(response)
                    callback(false, error)
                }
            } else {
                let error = createDBError(.internalError)
                callback(false, error)
            }
        }
        req.end()
    }

    func database_add(_ json: JSON, batch: Bool = false, callback: @escaping (DBDocumentInfo?, Swift.Error?) -> Void) {
        if let json_str = json.rawString() {
            var path: String = "/\(HTTP.escape(url: self.database.name))"
            if batch { path += "?batch=true" }

            let requestOptions = Utils.prepareRequest(
                self.database.configuration,
                method: "POST",
                path: path,
                hasBody: true
            )

            let req = HTTP.request(requestOptions, callback: { (response) in
                if let response = response {
                    if response.isEqual(to: .accepted, .OK) {
                        do {
                            let doc = try Utils.getBodyAsData(response)

                            let json = JSON(doc)
                            let _id = json["_id"].stringValue
                            let _rev = json["_rev"].stringValue

                            callback(DBDocumentInfo(_id: _id, _rev: _rev, json: json), nil)
                        } catch {
                            callback(nil, error)
                        }
                    } else {
                        let error = createDBError(response)
                        callback(nil, error)
                    }
                } else {
                    let error = createDBError(.internalError)
                    callback(nil, error)
                }
            })
            req.end(json_str)
        } else {
            let error = createDBError(.invalidJSON, reason: "Could not read the JSON")
            callback(nil, error)
        }
    }


}

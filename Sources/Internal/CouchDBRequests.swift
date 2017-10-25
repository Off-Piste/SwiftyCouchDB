//
//  CouchDBRequests.swift
//  SwiftyCouchDBPackageDescription
//
//  Created by Harry Wright on 23.10.17.
//

import Foundation
import SwiftyJSON

// FIXME: Adding Alamofire rather than KituraNet
// Works so much better than before, just may not work on linux yet, biggest downside
// but if its only just the Security Framework, will just use the ServerTrustPolicyRefactor branch

import Alamofire

//import KituraNet

//private extension ClientResponse {
//    func isEqual(to codes: HTTPStatusCode...) -> Bool {
//        for code in codes {
//            if self.statusCode != code { return false }
//        }
//
//        return true
//    }
//}

extension String {
    private var allowedCharacterSet: CharacterSet {
        return CharacterSet(charactersIn:"\"#%/<>?@\\^`{|} ").inverted
    }

    fileprivate var escaped: String {
        if let escaped = self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {
            return escaped
        }

        return self
    }
}

struct CouchDBRequestsUtils {

    static func createRequest(
         _ connProperties: DBConfiguration,
         method: HTTPMethod,
         path: String,
         body: JSON?,
         contentType: String = "application/json"
         ) throws -> URLRequest
    {
        let url = try connProperties.URL.asURL().appendingPathComponent(path.escaped)
        var headers: HTTPHeaders = [:]
        headers["Accept"] = "application/json"

        var request = try URLRequest(url: url, method: method, headers: headers)

        guard let body = body, let data = try? body.rawData() else { return request }

        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        return request
    }

}

class CouchDBRequests {

    typealias Utils = CouchDBRequestsUtils

    var databaseConfiguration: DBConfiguration

    var databaseName: String

    var sessionManager: SessionManager = SessionManager.default

    lazy var queue: DispatchQueue = {
        var queue = DispatchQueue(label: "io.couchdb.requests.\(UUID().uuidString)")
        return queue
    }()

    init(name: String, configuartion: DBConfiguration) {
        self.databaseName = name
        self.databaseConfiguration = configuartion
    }

}

extension CouchDBRequests {

    public func database_info(callback: @escaping (Data?, Swift.Error?) -> Void) {
        do {
            let request = try Utils.createRequest(
                databaseConfiguration,
                method: .get,
                path: "\(databaseName)",
                body: nil
            )

            self.sessionManager
                .request(request)
                .validate()
                .responseData(queue: queue) { (resp) in
                    callback(resp.data, resp.error)
            }
        } catch {
            callback(nil, error)
        }

//        let requestOptions = Utils.prepareRequest(
//            databaseConfiguration,
//            method: "GET",
//            path: "/\(HTTP.escape(url: databaseName))",
//            hasBody: false
//        )
//
//        let req = HTTP.request(requestOptions) { (response) in
//            if let response = response {
//                do {
//                    var data: Data? = try Utils.getBodyAsData(response)
//                    var error: Swift.Error?
//
//                    if response.statusCode != .OK {
//                        error = createDBError(response)
//                        data = nil
//                    }
//
//                    callback(data, error)
//                } catch {
//                    callback(nil, error)
//                }
//            } else {
//                let error = createDBError(.internalError)
//                callback(nil, error)
//            }
//        }
//        req.end()
    }

    public func database_exists(callback: @escaping (Bool, Swift.Error?) -> Void) {
        do {
            let request = try Utils.createRequest(
                databaseConfiguration,
                method: .head,
                path: "\(databaseName)",
                body: nil
            )

            self.sessionManager
                .request(request)
                .responseData(queue: queue) { (resp) in
                    switch resp.result {
                    case .success:
                        if resp.response!.statusCode == 200 {
                            callback(true, nil)
                        } else {
                            callback(false, nil)
                        }
                    case .failure(let error):
                        callback(false, error)
                    }
            }
        } catch {
            callback(false, error)
        }

//        let requestOptions = Utils.prepareRequest(
//            databaseConfiguration,
//            method: "HEAD",
//            path: "/\(HTTP.escape(url: databaseName))",
//            hasBody: false
//        )
//
//        let req = HTTP.request(requestOptions) { (response) in
//            if let response = response {
//                if response.statusCode == .OK { callback(true, nil); return }
//
//                // FIXME: Do we pass the error or not?
//                // The error is just 404, "not found", is it
//                // really worth passing, when we can just pass
//                // the only error worth noting (.internalError)
//                callback(false, nil)
//            } else {
//                let error = createDBError(.internalError)
//                callback(false, error)
//            }
//        }
//        req.end()
    }

    public func database_create(callback: @escaping (Database?, Swift.Error?) -> Void) {
        do {
            let request = try Utils.createRequest(
                databaseConfiguration,
                method: .put,
                path: "\(databaseName)",
                body: nil
            )

            self.sessionManager
                .request(request)
                .validate()
                .responseData(queue: self.queue) { (resp) in
                    switch resp.result {
                    case .success:
                        let databse = try! Database(
                            self.databaseName,
                            configuration: self.databaseConfiguration
                        )
                        callback(databse, nil)
                    case .failure(let error):
                        callback(nil, error)
                    }
            }
        } catch {
            callback(nil, error)
        }
//        let requestOptions = Utils.prepareRequest(
//            databaseConfiguration,
//            method: "PUT",
//            path: "/\(HTTP.escape(url: databaseName))",
//            hasBody: false
//        )
//
//
//        let req = HTTP.request(requestOptions) { (response) in
//            if let response = response {
//                if response.statusCode == .created {
//                    let database = try! Database(
//                        self.databaseName,
//                        configuration: self.databaseConfiguration
//                    )
//                    callback(database, nil)
//                } else {
//                    let error = createDBError(response)
//                    callback(nil, error)
//                }
//            } else {
//                let error = createDBError(.internalError)
//                callback(nil, error)
//            }
//        }
//        req.end()
    }

    public func database_delete(callback: @escaping (Bool, Swift.Error?) -> Void) {
//        let requestOptions = Utils.prepareRequest(
//            databaseConfiguration,
//            method: "DELETE",
//            path: "/\(HTTP.escape(url: databaseName))",
//            hasBody: false
//        )
//
//        let req = HTTP.request(requestOptions) { (response) in
//            if let response = response {
//                if response.statusCode == .OK {
//                    callback(true, nil)
//                } else if response.statusCode == .badRequest || response.statusCode == .notFound {
//                    callback(false, nil)
//                } else {
//                    // 401
//                    let error = createDBError(response)
//                    callback(false, error)
//                }
//            } else {
//                let error = createDBError(.internalError)
//                callback(false, error)
//            }
//        }
//        req.end()
    }

    func database_add(_ json: JSON, batch: Bool = false, callback: @escaping (DBDocumentInfo?, Swift.Error?) -> Void) {
//        if let json_str = json.rawString() {
//            var path: String = "/\(HTTP.escape(url: databaseName))"
//            if batch { path += "?batch=true" }
//
//            let requestOptions = Utils.prepareRequest(
//                databaseConfiguration,
//                method: "POST",
//                path: path,
//                hasBody: true
//            )
//
//            let req = HTTP.request(requestOptions, callback: { (response) in
//                if let response = response {
//                    if response.isEqual(to: .accepted, .OK) {
//                        do {
//                            let doc = try Utils.getBodyAsData(response)
//
//                            let json = JSON(doc)
//                            let _id = json["_id"].stringValue
//                            let _rev = json["_rev"].stringValue
//
//                            callback(DBDocumentInfo(_id: _id, _rev: _rev, json: json), nil)
//                        } catch {
//                            callback(nil, error)
//                        }
//                    } else {
//                        let error = createDBError(response)
//                        callback(nil, error)
//                    }
//                } else {
//                    let error = createDBError(.internalError)
//                    callback(nil, error)
//                }
//            })
//            req.end(json_str)
//        } else {
//            let error = createDBError(.invalidJSON, reason: "Could not read the JSON")
//            callback(nil, error)
//        }
    }


}

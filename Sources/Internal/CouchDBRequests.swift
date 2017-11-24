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

extension URLComponents {
    init(url: URLConvertible) throws {
        guard let comps = URLComponents(url: try url.asURL(), resolvingAgainstBaseURL: true) else {
            throw createDBError(.invalidURL)
        }
        self = comps
    }
}

extension String {
    private var allowedCharacterSet: CharacterSet {
        return CharacterSet(charactersIn:"\"#%/<>?@\\^`{|} ").inverted
    }

    internal var escaped: String {
        if let escaped = self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {
            return escaped
        }

        return self
    }
}

class CouchDBRequests {

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

    func database_info(callback: @escaping (Data?, Swift.Error?) -> Void) {
        let request = CouchDBRequest(
            databaseConfiguration,
            path: self.databaseName.escaped,
            method: .get
        )

        self.sessionManager
            .request(request)
            .validate()
            .responseData(queue: queue) { (resp) in
                callback(resp.data, resp.error)
        }
    }

    func database_exists(callback: @escaping (Bool, Swift.Error?) -> Void) {
        let request = CouchDBRequest(
            databaseConfiguration,
            path: self.databaseName.escaped,
            method: .head
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
    }

    func database_create(callback: @escaping (Database?, Swift.Error?) -> Void) {
        let request = CouchDBRequest(
            databaseConfiguration,
            path: databaseName.escaped,
            method: .put
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
    }

    func database_delete(callback: @escaping (Bool, Swift.Error?) -> Void) {
        let request = CouchDBRequest(
            databaseConfiguration,
            path: databaseName.escaped,
            method: .delete
        )

        self.sessionManager
            .request(request)
            .validate()
            .responseData(queue: self.queue, completionHandler: { (resp) in
                switch resp.result {
                case .success: callback(true, nil)
                case .failure(let error): callback(false, error)
                }
            })
    }

    func database_add(_ json: JSON, batch: Bool = false, callback: @escaping (DBDocumentInfo?, Swift.Error?) -> Void) {
        guard json.error == nil else { callback(nil, json.error); return }

        var parameters: Parameters?
        if batch {
            parameters = [:]
            parameters?["batch"] = batch
        }

        let request = CouchDBRequest(
            databaseConfiguration,
            path: databaseName.escaped,
            method: .post,
            parameters: parameters
        )
        request.json = json

        self.sessionManager.request(request).validate().responseJSON(queue: queue) { (resp) in
            switch resp.result {
            case .success(let value):
                let json = JSON(value)
                let _id = json["id"].exists() ? json["id"].stringValue : json["_id"].stringValue
                let _rev = json["rev"].exists() ? json["rev"].stringValue : json["_rev"].stringValue
                callback(DBDocumentInfo(_id: _id, _rev: _rev, json: json), nil)
            case .failure(let error):
                callback(nil, error)
            }
        }
    }

    func database_retrieve(
        _ id: String,
        parameters: Parameters?,
        callback: @escaping (DBDocumentInfo?, Error?) -> Void
        )
    {
        let request = CouchDBRequest(
            databaseConfiguration,
            path: "\(databaseName.escaped)/\(id.contains("/") ? id : id.escaped)",
            method: .get,
            parameters: parameters
        )

        self.sessionManager.request(request).validate().responseJSON(queue: queue) { (resp) in
            switch resp.result {
            case .success(let value):
                let json = JSON(value)
                let _id = json["id"].exists() ? json["id"].stringValue : json["_id"].stringValue
                let _rev = json["rev"].exists() ? json["rev"].stringValue : json["_rev"].stringValue
                callback(DBDocumentInfo(_id: _id, _rev: _rev, json: json), nil)
            case .failure(let error):
                callback(nil, error)
            }
        }
    }

    func doc_delete(_ id: String, callback: @escaping (Bool, Error?) -> Void) {
        let request = CouchDBRequest(
            databaseConfiguration,
            path: "\(databaseName.escaped)/\(id.contains("/") ? id : id.escaped)",
            method: .delete
        )

        self.sessionManager.request(request).validate().responseJSON(queue: queue) { (resp) in
            switch resp.result {
            case .success: callback(true, nil)
            case .failure(let error): callback(false, error)
            }
        }
    }

    func doc_update(
        _ id: String,
        rev: String,
        json: JSON,
        callback: @escaping (DBDocumentInfo?, Error?) -> Void
        )
    {
        guard json.error == nil else {
            callback(nil, json.error)
            return
        }

        let request = CouchDBRequest(
            databaseConfiguration,
            path: "\(databaseName.escaped)/\(id.contains("/") ? id : id.escaped)",
            method: .put,
            parameters: ["rev":rev]
        )
        request.json = json

        self.sessionManager.request(request).validate().responseJSON(queue: queue) { (resp) in
            switch resp.result {
            case .success(let value):
                let json = JSON(value)
                let _id = json["id"].exists() ? json["id"].stringValue : json["_id"].stringValue
                let _rev = json["rev"].exists() ? json["rev"].stringValue : json["_rev"].stringValue
                callback(DBDocumentInfo(_id: _id, _rev: _rev, json: json), nil)
            case .failure(let error):
                callback(nil, error)
            }
        }
    }

}

extension CouchDBRequests {

    func query(
        by view: String,
        in design: String,
        with parameters: Parameters,
        callback: @escaping (JSON?, Error?) -> Void
        )
    {
        let request = CouchDBRequest(
            databaseConfiguration,
            path: "\(databaseName.escaped)/\(design)/_view/\(view.escaped)",
            method: .get,
            parameters: parameters
        )

        self.sessionManager.request(request).validate().responseData { (resp) in
            switch resp.result {
            case .success(let data): callback(JSON(data: data), nil)
            case .failure(let error): callback(nil, error)
            }
        }
    }
    
}

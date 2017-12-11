//
//  CouchDB.swift
//  CouchDB
//
//  Created by Harry Wright on 23.10.17.
//  Copyright © 2017 Trolley. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public typealias CouchDBServerResponse = (JSON?, Swift.Error?) -> Void

public final class CouchDB {

    internal static var queue: DispatchQueue = DispatchQueue(label: "io.op.couchDB")

    /// GET /_active_tasks
    ///
    /// - Parameter callback: `(JSON?, Swift.Error?) -> Void`
    public static func activeTasks(callback: @escaping CouchDBServerResponse) {
        do {
            var baseURL = try DBConfiguration.default.url.asURL()
            baseURL.appendPathComponent("_active_tasks")

            request(baseURL).responseData(queue: queue, completionHandler: { (resp) in
                switch resp.result {
                case .success(let data): callback(JSON(data: data), nil)
                case .failure(let error): callback(nil, error)
                }
            })
        } catch {
            callback(nil, error)
        }
    }

    /// GET /_all_dbs
    ///
    /// - Parameter callback: `(JSON?, Swift.Error?) -> Void`
    public static func allDatabases(callback: @escaping CouchDBServerResponse) {
        do {
            var baseURL = try DBConfiguration.default.url.asURL()
            baseURL.appendPathComponent("_all_dbs")

            request(baseURL).responseData(queue: queue, completionHandler: { (resp) in
                switch resp.result {
                case .success(let data): callback(JSON(data: data), nil)
                case .failure(let error): callback(nil, error)
                }
            })
        } catch {
            callback(nil, error)
        }
    }


    /// GET /_db_updates
    ///
    /// - Parameter callback: `(JSON?, Swift.Error?) -> Void`
    public static func dbUpdates(callback: @escaping CouchDBServerResponse) {
        do {
            var baseURL = try DBConfiguration.default.url.asURL()
            baseURL.appendPathComponent("_db_updates")

            request(baseURL).responseData(queue: queue, completionHandler: { (resp) in
                switch resp.result {
                case .success(let data): callback(JSON(data: data), nil)
                case .failure(let error): callback(nil, error)
                }
            })
        } catch {
            callback(nil, error)
        }
    }

    /// POST /_restart
    ///
    /// - Parameter callback: `(JSON?, Swift.Error?) -> Void`
    public static func restart(callback: @escaping CouchDBServerResponse) {
        do {
            var baseURL = try DBConfiguration.default.url.asURL()
            baseURL.appendPathComponent("_restart")

            request(baseURL).responseData(queue: queue, completionHandler: { (resp) in
                switch resp.result {
                case .success(let data): callback(JSON(data: data), nil)
                case .failure(let error): callback(nil, error)
                }
            })
        } catch {
            callback(nil, error)
        }
    }

    /// GET /_stats
    ///
    /// - Parameter callback: `(JSON?, Swift.Error?) -> Void`
    public static func stats(callback: @escaping CouchDBServerResponse) {
        do {
            var baseURL = try DBConfiguration.default.url.asURL()
            baseURL.appendPathComponent("_stats")

            request(baseURL).responseData(queue: queue, completionHandler: { (resp) in
                switch resp.result {
                case .success(let data): callback(JSON(data: data), nil)
                case .failure(let error): callback(nil, error)
                }
            })
        } catch {
            callback(nil, error)
        }
    }

    /// GET /_uuids
    ///
    /// - Parameter callback: `(JSON?, Swift.Error?) -> Void`
    public static func uuids(callback: @escaping CouchDBServerResponse) {
        do {
            var baseURL = try DBConfiguration.default.url.asURL()
            baseURL.appendPathComponent("_uuids")

            request(baseURL).responseData(queue: queue, completionHandler: { (resp) in
                switch resp.result {
                case .success(let data): callback(JSON(data: data), nil)
                case .failure(let error): callback(nil, error)
                }
            })
        } catch {
            callback(nil, error)
        }
    }

}

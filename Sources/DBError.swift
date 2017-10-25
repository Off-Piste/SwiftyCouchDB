//
//  DBError.swift
//  CouchDB
//
//  Created by Harry Wright on 23.10.17.
//  Copyright © 2017 Trolley. All rights reserved.
//

import Foundation
//import KituraNet

let kDBErrorDomain = "io.off_piste.swifty_couch_db.error"

enum DBErrorCode: Int {
    case couchNotRunning = 1
    case invalidDatabase = 100
    case invalidURL = 101
    case incompatableDatabase = 999
    case invalidJSON = 901
    case invalidRequest = 404
    case internalError = 500
}

//func createDBError(_ response: ClientResponse) -> Swift.Error {
//    do {
//        var json = try CouchDBRequestsUtils.getBodyAsJson(response)
//        return createDBError(response.statusCode.rawValue, reason: json.string)
//    } catch {
//        return error
//    }
//}

func createDBError(_ code: DBErrorCode, reason: String? = nil) -> Swift.Error {
    return createDBError(code.rawValue, reason: reason)
}

func createDBError(_ code: Int, reason: String? = nil) -> Swift.Error {
    var userInfo: [String: Any] = ["Code": code]
    if let errorReason = reason {
        userInfo.updateValue(errorReason, forKey: NSLocalizedDescriptionKey)
    }
    return NSError(domain: kDBErrorDomain, code: code, userInfo: userInfo)
}

//
//  Core.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 08.08.17.
//
//

import Foundation
import KituraNet
@_exported import SwiftyJSON

internal enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}

struct CouchDBCore {

    var connectionProperties: ConnectionProperties

    struct Utils {

        static func prepareRequest(
            for connectionProperties: ConnectionProperties,
            method: HTTPMethod,
            path: String,
            hasBody: Bool,
            contentType: String = "application/json"
            ) -> [ClientRequest.Options]
        {
            var headers = [String:String]()
            headers["Accept"] = "application/json"
            if hasBody {
                headers["Content-Type"] = contentType
            }

            var requestOptions: [ClientRequest.Options] = []
            if let username = connectionProperties.username {
                requestOptions.append(.username(username))
            }
            if let password = connectionProperties.password {
                requestOptions.append(.password(password))
            }

            requestOptions.append(.schema("\(connectionProperties.HTTPProtocol)://"))
            requestOptions.append(.hostname(connectionProperties.host))
            requestOptions.append(.port(connectionProperties.port))
            requestOptions.append(.method(method.rawValue))
            requestOptions.append(.path(path))
            requestOptions.append(.headers(headers))
            return requestOptions
        }

        static func getBodyAsJSON(for response: ClientResponse) throws -> JSON {
            var body = Data()
            try response.readAllData(into: &body)
            return JSON(data: body)
        }

        static func getBodyAsData(for response: ClientResponse) throws -> Data {
            var body = Data()
            try response.readAllData(into: &body)
            return body
        }
    }

}

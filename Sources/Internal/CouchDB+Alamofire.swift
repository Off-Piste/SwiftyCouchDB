//
//  CouchDB+Alamofire.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 30.10.17.
//

import Foundation
import Alamofire
import SwiftyJSON

class CouchDBRequest: URLRequestConvertible {

    var config: DBConfiguration

    var path: String

    var parameters: Parameters?

    var encoding: URLEncoding

    var headers: HTTPHeaders?

    var method: HTTPMethod

    var json: JSON? = .null

    init(
        _ config: DBConfiguration,
        path: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        encoding: URLEncoding = .queryString,
        headers: HTTPHeaders? = nil
        )
    {
        self.config = config
        self.path = path
        self.method = method
        self.parameters = parameters?.count != 0 ? parameters : nil
        self.encoding = encoding
        self.headers = headers?.count != 0 ? headers : nil
    }

    func manageURL(_ url: URLConvertible) throws -> URL {
        var baseURL = try url.asURL()
        baseURL.appendPathComponent(path)

        // Use Alamofires request builder to place the parameteres right
        // saves us building a function to do the same thing
        let req = request(baseURL, method: .get, parameters: parameters, encoding: encoding)
        return req.request?.url ?? baseURL
    }

    func asURLRequest() throws -> URLRequest {
        let url = try self.manageURL(self.config.URL)
        var request = try URLRequest(url: url, method: method, headers: headers)

        if let json = self.json, let data = try? json.rawData() {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
        }
        return request
    }
}

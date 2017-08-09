//
//  Error.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 08.08.17.
//
//

import Foundation
import KituraNet

public typealias SError = Swift.Error

fileprivate let domain: String = "io.offpist.swiftycouchdb"

func SwiftError(_ reason: String, _ code: Int) -> SError {
    return NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey : reason])
}

extension Database {

    public struct Error {

        public static let invalidJSON: SError = SwiftError("Invalid JSON", -100)

        public static let internalError: SError = SwiftError("Internal Error", -000)

        public static let databaseDoesntExist: SError = SwiftError("The database does not exist", 404)

        public static let nilConnectionProperties: SError = SwiftError("Connection properties have not been set", -404)

        public static func invalidStatusCode(_ code: HTTPStatusCode) -> SError {
            let error = NSError(domain: domain, code: code.rawValue, userInfo: nil)
            return Database.Error(_nsError: error).error
        }

        public static func couchDBError(_ json: String, code: HTTPStatusCode) -> SError {
            return SwiftError(json, code.rawValue)
        }

        public static func propertyNotFound(forKey key: String) -> SError {
            return SwiftError("Could not find the property for key: \(key)", -101)
        }

        public static func invalidConverion<F, T>(from: F, to: T) -> SError {
            return SwiftError("Could not convert from [\(from), to [\(to)]]", -102)
        }

        public var error: SError {
            return _nsError
        }

        private var _nsError: NSError

        internal init(_nsError error: NSError) {
            _nsError = error
        }
    }

}

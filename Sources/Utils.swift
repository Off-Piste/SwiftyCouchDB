//
//  Utils.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 25.07.17.
//
//

import Foundation
import CouchDB

/// <#Description#>
public struct ConnectionPropertiesManager {

    /// <#Description#>
    public static var connectionProperties: ConnectionProperties?

    private init() {
        fatalError("Should never be called")
    }
}

func createError(_ reason: String, code: Int = 100) -> Error {
    return NSError(
        domain: "SwiftyCouchDB",
        code: code,
        userInfo: [NSLocalizedDescriptionKey: reason]
    )
}

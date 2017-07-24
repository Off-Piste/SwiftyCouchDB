//
//  Utils.swift
//  SwiftyCouchCB
//
//  Created by Harry Wright on 24.07.17.
//
//

import Foundation
import SwiftyJSON

internal struct DatabaseFile {

    public var name: String

}

internal struct DatabaseDesign {

    public var name: String

}

public struct DatabaseSnapshot {

    public var id: String

    public var rev: String

    public var json: JSON

    internal var originalJSON: JSON

}

public typealias CouchDBSnapshot = (DatabaseSnapshot?, Error?) -> Void

internal func createError(_ reason: String) -> Error {
    return NSError(domain: "db", code: -100, userInfo: [NSLocalizedDescriptionKey : reason]) as Error
}

internal func invalidJSONError(for value: Any, jsonType: Type) -> Error {
    let type = type(of: value)
    return createError("The JSON node required the object [\(value)](\(type)) to be of type [\(jsonType)]")
}

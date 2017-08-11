//
//  DatabaseObject.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 08.08.17.
//
//

import Foundation

open class DatabaseObject: DatabaseObjectBase {

    private var requiredDBProperties: [String] = ["_id", "_rev", "type", "id"]

}

extension DatabaseObject {

    open func hiddenProperties() -> [String] { return [] }

    open func nonDataProperties() -> [String] { return [] }
    
}

public final class User: DatabaseObject {

    dynamic var id: String = ""

    dynamic var roles: [String] = []

    dynamic var password: String = ""

    dynamic var username: String = ""

    dynamic var email: String = ""

}

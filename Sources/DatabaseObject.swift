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

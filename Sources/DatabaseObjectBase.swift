//
//  DatabaseObjectBase.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 08.08.17.
//
//

import Foundation

open class DatabaseObjectBase: NSObject {

    open var database: Database?

    open override var className: String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last ?? "nil"
    }

}

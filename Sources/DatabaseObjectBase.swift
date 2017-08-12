//
//  DatabaseObjectBase.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 08.08.17.
//
//

import Foundation

/** */
open class DatabaseObjectBase: NSObject {

    /// <#Description#>
    final public var database: Database?

    /// <#Description#>
    final public override var className: String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last ?? "nil"
    }

}

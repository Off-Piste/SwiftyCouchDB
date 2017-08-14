//
//  DatabaseObjectBase.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 08.08.17.
//
//

import Foundation

public enum ObjectState {
    case created
    case deleted
    case unknown
}

/** */
open class DatabaseObjectBase: NSObject {

    /// <#Description#>
    final public var state: ObjectState = .unknown

    /// <#Description#>
    open var database: Database? {
        return try? Database(className.lowercased())
    }

    /// <#Description#>
    final public override var className: String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last ?? "nil"
    }

}

// MARK: - Depreciations
extension DatabaseObjectBase {

    @available(*, unavailable, renamed: "isEqual(toObject:)")
    open override func isEqual(to object: Any?) -> Bool { fatalError("Use `isEqual(toObject:)`") }

    @available(*, unavailable, renamed: "isEqual(toObject:)")
    open override func isLike(_ object: String) -> Bool { fatalError("") }

    @available(*, unavailable, renamed: "isEqual(toObject:)")
    open override func isLessThan(_ object: Any?) -> Bool { fatalError("") }

    @available(*, unavailable, renamed: "isEqual(toObject:)")
    open override func isGreaterThan(_ object: Any?) -> Bool { fatalError() }

    @available(*, unavailable, renamed: "isEqual(toObject:)")
    open override func isLessThanOrEqual(to object: Any?) -> Bool { fatalError() }

    @available(*, unavailable, renamed: "isEqual(toObject:)")
    open override func isGreaterThanOrEqual(to object: Any?) -> Bool { fatalError() }

    @available(*, unavailable, renamed: "isEqual(toObject:)")
    open override func isCaseInsensitiveLike(_ object: String) -> Bool { fatalError() }

}

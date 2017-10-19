//
//  DatabaseObjectBase.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 08.08.17.
//
//

import Foundation
import SwiftyJSON

public enum ObjectState {
    case created
    case deleted
    case unknown
}

func +=<K, V> (lhs: inout [K: V], rhs: [K: V]) {
    for (key, value) in rhs {
        lhs.updateValue(value, forKey: key)
    }
}

extension Dictionary where Key == String, Value == Any {
    func flatten() -> Dictionary {
        let dict = self.reduce([:]) { (result, touple) -> [String : Any] in
            var dict: [String: Any] = result
            if touple.key == "data", let toupleDict = touple.value as? [String: Any] {
                dict += toupleDict
            } else {
                dict.updateValue(touple.value, forKey: touple.key)
            }

            return dict
        }

        return dict
    }
}

/** */
open class DatabaseObjectBase: NSObject {

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

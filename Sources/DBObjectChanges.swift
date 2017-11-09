//
//  CouchDBChanges.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 31.10.17.
//

import Foundation
import SwiftyJSON

internal struct DBProperty {
    var label: String
    var value: Any
}

internal extension JSON {
    var toProperties: [DBProperty] {
        return self.map { DBProperty(label: $0.0, value: $0.1.object) }
    }
}

extension Array where Element == DBProperty {
    subscript(_ element: Element) -> Element? {
        for child in self {
            if child.label == element.label { return child }
        }

        return nil
    }
}

public struct DBPropertyChange {
    /**
     The name of the property which changed.
     */
    public let name: String

    /**
     Value of the property before the change occurred. This is not supplied if
     the change happened on the same thread as the notification and for `List`
     properties.

     For object properties this will give the object which was previously
     linked to, but that object will have its new values and not the values it
     had before the changes. This means that `previousValue` may be a deleted
     object, and you will need to check `isInvalidated` before accessing any
     of its properties.
     */
    public let oldValue: Any?

    /**
     The value of the property after the change occurred. This is not supplied
     for `List` properties and will always be nil.
     */
    public let newValue: Any?
}

public enum DBObjectChange {
    /**
     If an error occurs, notification blocks are called one time with a `.error`
     result and an `NSError` containing details about the error. Currently the
     only errors which can occur are when opening the Realm on a background
     worker thread to calculate the change set. The callback will never be
     called again after `.error` is delivered.
     */
    case error(Error)
    /**
     One or more of the properties of the object have been changed.
     */
    case changes([DBPropertyChange])
    /// The object has been deleted from the CouchDB.
    case deleted
}

func checkChanges(from old: [DBProperty], to new: [DBProperty]) -> [DBPropertyChange] {
    var removed = old
        .filter { $0.label != new[$0]?.label }
        .map { DBPropertyChange.init(name: $0.label, oldValue: $0.value, newValue: nil) }

    let additions = new
        .filter { $0.label != old[$0]?.label }
        .map { DBPropertyChange.init(name: $0.label, oldValue: nil, newValue: $0.value) }

    let changes = new
        .filter { $0.label == old[$0]?.label }
        .map { newChild -> DBPropertyChange? in
            if newChild.value as? AnyHashable != old[newChild]!.value as? AnyHashable {
                return DBPropertyChange(
                    name: newChild.label,
                    oldValue: old[newChild]?.value,
                    newValue: newChild.value
                )
            }
            return nil
        }.flatMap { $0 }

    removed.append(contentsOf: additions)
    removed.append(contentsOf: changes)
    return removed
}

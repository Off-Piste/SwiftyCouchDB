//
//  JSONableProperty.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 10.08.17.
//
//

import Foundation

public protocol JSONAbleProperty {
    // workaround for 
    // https://stackoverflow.com/questions/37141067/a-swift-protocol-requirement-that-can-only-be-satisfied-by-using-a-final-class
    associatedtype Object
    var object: Object { get }
}

extension Int : JSONAbleProperty { public var object: Int { return self } }
extension Double : JSONAbleProperty { public var object: Double { return self } }
extension Float: JSONAbleProperty { public var object: Float { return self } }
extension NSNumber: JSONAbleProperty { public var object: NSNumber { return self } }
extension NSString: JSONAbleProperty { public var object: NSString { return self } }
extension String: JSONAbleProperty { public var object: String { return self } }
extension Array: JSONAbleProperty { public var object: [Element] { return self }}
extension Bool: JSONAbleProperty { public var object: Bool { return self } }
extension Dictionary: JSONAbleProperty { public var object: [Key : Value] { return self } }
extension NSNull: JSONAbleProperty { public var object: NSNull { return self } }
extension DatabaseObject: JSONAbleProperty { final public var object: DatabaseObject { return self } }

// swiftlint:disable force_cast
func == <Object: JSONAbleProperty>(lhs: Object, rhs: Object) -> Bool {
    if (lhs.object is Int) && (rhs.object is Int) {
        return (lhs.object as! Int) == (rhs.object as! Int)
    } else if (lhs.object is Double) && (rhs.object is Double) {
        return (lhs.object as! Double) == (rhs.object as! Double)
    } else if (lhs.object is Float) && (rhs.object is Float) {
        return (lhs.object as! Float) == (rhs.object as! Float)
    } else if (lhs.object is NSNumber) && (rhs.object is NSNumber) {
        return (lhs.object as! NSNumber).isEqual(to: rhs.object as! NSNumber)
    } else if (lhs.object is NSString) && (rhs.object is NSString) {
        return (lhs.object as! NSString).isEqual(rhs.object as! NSString)
    } else if (lhs.object is String) && (rhs.object is String) {
        return (lhs.object as! String) == (rhs.object as! String)
    } else if (lhs.object is [Any]) && (rhs.object is [Any]) {
        return (lhs.object as! [Any]) == (rhs.object as! [Any])
    } else if (lhs.object is [AnyHashable: Any]) && (rhs.object is [AnyHashable: Any]) {
        return (lhs.object as! [AnyHashable: Any]) == (rhs.object as! [AnyHashable: Any])
    } else if (lhs.object is NSNull) && (rhs.object is NSNull) {
        return true
    } else if (lhs.object is DatabaseObject) && (rhs.object is DatabaseObject) {
        return (lhs.object as! DatabaseObject) == (rhs.object as! DatabaseObject)
    } else {
        return false
    }
}
// swiftlint:enable force_cast

func != <Object: JSONAbleProperty>(lhs: Object, rhs: Object) -> Bool {
    return !(lhs == rhs)
}

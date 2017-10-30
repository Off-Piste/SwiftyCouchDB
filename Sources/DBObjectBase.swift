//
//  BDObjectBase.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 30.10.17.
//

import Foundation

public struct Utils {

    public static var encoder: JSONEncoder = JSONEncoder()

    public static var decoder: JSONDecoder = JSONDecoder()

}

func isSwiftClassName(_ className: NSString) -> Bool {
    return className.range(of: ".").location != NSNotFound
}

func demangleSwiftClass(_ className: NSString) -> NSString {
    return className.substring(from: className.range(of: ".").location + 1) as NSString
}


open class DBObjectBase: Codable {

    public init() { }

    public required init(from decoder: Decoder) throws { }

    open class var database: Database? {
        let class_string: NSString = NSStringFromClass(self).lowercased() as NSString
        if isSwiftClassName(class_string) {
            return try? Database(demangleSwiftClass(class_string) as String)
        } else {
            return try? Database(class_string as String)
        }
    }

}

extension DBObjectBase: Hashable {

    public var hashValue: Int {
        let data = try? Utils.encoder.encode(self)
        return data?.hashValue ?? 1 ^ 1
    }

    public static func ==(lhs: DBObjectBase, rhs: DBObjectBase) -> Bool {
        guard let lhs_data = try? Utils.encoder.encode(lhs),
            let rhs_data = try? Utils.encoder.encode(rhs) else { return false }

        return lhs_data == rhs_data
    }

}

extension DBObjectBase {

    public final func add(callback: (Bool, Swift.Error?) -> Void) { fatalError() }

    public final func update(callback: ([DBObjectChanges]?, Swift.Error?) -> Void) { fatalError() }

    public final func delete(callback: (Bool, Swift.Error?) -> Void) { fatalError() }

}

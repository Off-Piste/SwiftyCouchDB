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

    /// <#Description#>
    public init() { }

    /// <#Description#>
    ///
    /// - Parameter decoder: <#decoder description#>
    /// - Throws: <#throws value description#>
    public required init(from decoder: Decoder) throws { }

    /// <#Description#>
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

    /// <#Description#>
    public var hashValue: Int {
        let data = try? Utils.encoder.encode(self)
        return data?.hashValue ?? 1 ^ 1
    }

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - lhs: <#lhs description#>
    ///   - rhs: <#rhs description#>
    /// - Returns: <#return value description#>
    public static func ==(lhs: DBObjectBase, rhs: DBObjectBase) -> Bool {
        guard let lhs_data = try? Utils.encoder.encode(lhs),
            let rhs_data = try? Utils.encoder.encode(rhs) else { return false }

        return lhs_data == rhs_data
    }

}

extension DBObjectBase {

    /// <#Description#>
    ///
    /// - Parameter callback: <#callback description#>
    public final func add(callback: @escaping (Bool, Swift.Error?) -> Void) {
        guard let database = type(of: self).database else {
            callback(false, createDBError(.invalidDatabase, reason: "Database is nil"))
            return
        }
        
        database.add(self, callback: { (info, error) in
            if let error = error {
                callback(false, error)
            } else {
                callback(true, nil)
            }
        })
    }

    /// <#Description#>
    ///
    /// - Parameter callback: <#callback description#>
    public final func update(callback: ([DBObjectChanges]?, Swift.Error?) -> Void) { fatalError() }

    /// <#Description#>
    ///
    /// - Parameter callback: <#callback description#>
    public final func delete(callback: (Bool, Swift.Error?) -> Void) { fatalError() }

}

//
//  BDObjectBase.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 30.10.17.
//

import Foundation
import SwiftyJSON

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

public typealias Object = DBObjectBase

open class DBObjectBase: Codable {

    /// The default Init
    public init() { }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public required init(from decoder: Decoder) throws { }

    /// The Database the Object uses
    ///
    /// - Note: Defaults to `NSStringFromClass(self).lowercased()`
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

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int {
        let data = try? Utils.encoder.encode(self)
        return data?.hashValue ?? 1 ^ 1
    }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: DBObjectBase, rhs: DBObjectBase) -> Bool {
        guard let lhs_data = try? Utils.encoder.encode(lhs),
            let rhs_data = try? Utils.encoder.encode(rhs) else { return false }

        return lhs_data == rhs_data
    }

}

extension DBObjectBase {

    /// Method used to get a specific Object.
    ///
    /// Using this method is the same as calling this with curl:
    ///
    /// ```bash
    /// curl -X GET 127.0.0.1:5984/database_name/id
    ///
    /// - Parameters:
    ///   - id: The ID of the object
    ///   - callback: The decoded object if the request is sucessful or the error if not
    public static func retrieve(_ id: String, callback: @escaping (Object?, Error?) -> Void) {
        guard let database = self.database else {
            callback(nil, createDBError(.invalidDatabase, reason: "Database is nil"))
            return
        }

        database.retrieve(id) { (info, error) in
            if let error = error {
                callback(nil, error)
            } else {
                do {
                    let data = try info!.json.rawData()
                    let object = try Utils.decoder.decode(self, from: data)
                    callback(object, nil)
                } catch {
                    callback(nil, error)
                }
            }
        }

    }

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
    public final func update(callback: @escaping (DBObjectChange) -> Void) {
        guard let db = type(of: self).database else {
            callback(.error(createDBError(.invalidDatabase, reason: "Database is nil")))
            return
        }

        do {
            let object = self
            let data = try Utils.encoder.encode(object)
            let newJSON = JSON(data: data)

            db.update((object as! DBObject).id, with: newJSON, callback: callback)
        } catch {
            callback(.error(error))
        }
    }

    /// <#Description#>
    ///
    /// - Parameter callback: <#callback description#>
    public final func delete(callback: @escaping (Bool, Swift.Error?) -> Void) {
        guard let db = type(of: self).database else {
            callback(false, createDBError(.invalidDatabase, reason: "Database is nil"))
            return
        }

        db.deleteObject((self as! DBObject).id, callback: callback)
    }

}


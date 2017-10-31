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
    public final func update(callback: @escaping (DBObjectChange) -> Void) {
        guard let db = type(of: self).database else {
            callback(.error(createDBError(.invalidDatabase, reason: "Database is nil")))
            return
        }

        // 1. Retrieve the old object
        // Id is not set yet and the User should only use DBObject not DBObjectBase
        db.retrieve((self as! DBObject).id) { (info, err) in
            if let info = info {
                // 2. Get the oldProperties
                let oldProperies = info.json.toProperties

                do {
                    // 3. Encode the object to JSON
                    let object = self
                    let data = try Utils.encoder.encode(object)
                    let newJSON = JSON(data: data)

                    // 4. Set the new Properties
                    let newProperies = newJSON.toProperties

                    // 5. Update the documents
                    db.request.doc_update(info._id, rev: info._rev, json: newJSON) { (info, err) in
                        if let err = err {
                            callback(.error(err))
                        } else {
                            // 6. Check for changes and pass changes back
                            let changes = checkChanges(from: oldProperies, to: newProperies)
                            callback(.changes(changes))
                        }
                    }
                } catch {
                    callback(.error(error))
                }
            } else {
                // If the error code is 404, safe to assume the object has been deleted
                if err!._code == 404 {
                    callback(.deleted)
                } else {
                    callback(.error(err!))
                }
            }
        }
    }

    /// <#Description#>
    ///
    /// - Parameter callback: <#callback description#>
    public final func delete(callback: (Bool, Swift.Error?) -> Void) { fatalError() }

}


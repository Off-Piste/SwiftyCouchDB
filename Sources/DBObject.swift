//
//  DBObject.swift
//  CouchDB
//
//  Created by Harry Wright on 22.10.17.
//  Copyright © 2017 Trolley. All rights reserved.
//

import Foundation
@_exported import CodableCollection

extension String {
    mutating func replaceOccurrences<Target, Replacement>(of target: Target, with replacement: Replacement, options: String.CompareOptions = [], range searchRange: Range<String.Index>? = nil) where Target : StringProtocol, Replacement : StringProtocol {
        self = self.replacingOccurrences(of: target, with: replacement, options: options, range: searchRange)
    }
}

public protocol DBDocument: Codable {
    
    var _id: String { get set }
    
    static var database: Database? { get }
    
}

public extension DBDocument {
    
    static var database: Database? {
        // Workaround for NSStringForClass
        let mirror = Mirror(reflecting: self)
        var subjectType: String = "\(mirror.subjectType)".lowercased()
        if subjectType.contains(".type") {
            subjectType.replaceOccurrences(of: ".type", with: "")
        }
        
        return try? Database(subjectType)
    }
    
}

extension DBDocument {
    
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
    public static func retrieve(_ id: String, callback: @escaping (Self?, Error?) -> Void) {
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
    public func add(callback: @escaping (Bool, Swift.Error?) -> Void) {
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
    public func delete(callback: @escaping (Bool, Swift.Error?) -> Void) {
        guard let db = type(of: self).database else {
            callback(false, createDBError(.invalidDatabase, reason: "Database is nil"))
            return
        }
        
        db.deleteObject(self._id, callback: callback)
    }
    
    /// <#Description#>
    ///
    /// - Parameter callback: <#callback description#>
    public func update(callback: @escaping (DBObjectChange) -> Void) {
        guard let db = type(of: self).database else {
            callback(.error(createDBError(.invalidDatabase, reason: "Database is nil")))
            return
        }
        
        do {
            let object = self
            let newJSON = try Utils.encoder.encodeJSON(object)
            
            db.update(object._id, with: newJSON, callback: callback)
        } catch {
            callback(.error(error))
        }
    }
    
//    /// Method to be used when you wish to add an object to an array inside an Object but
//    /// don't know the previous contents of the Array
//    ///
//    /// Using Swift 4's WritableKeyPath you can choose the path you wish to update when the
//    /// object is retrieved
//    ///
//    /// - Parameters:
//    ///   - change: <#change description#>
//    ///   - keyPath: <#keyPath description#>
//    ///   - callback: <#callback description#>
//    public final func addChange<Change: Codable, Sequence: RangeReplaceableCollection>(
//        _ change: Change,
//        forKeyPath keyPath: WritableKeyPath<DBObjectBase, Sequence>,
//        callback: @escaping (DBObjectChange) -> Void
//        ) where Sequence.Element == Change
//    {
//        // 1. Retrieve the document
//        guard let db = type(of: self).database else {
//            callback(.error(createDBError(.invalidDatabase, reason: "Database is nil")))
//            return
//        }
//        
//        db.retrieve((self as! DBObject).id) { (info, error) in
//            if let error = error as? AFError, error.responseCode == 404 {
//                var newObject = self
//                newObject[keyPath: keyPath].append(change)
//            } else if let error = error {
//                callback(.error(error))
//            }
//        }
//        
//        // 2. Check the errors
//        
//        // 3. If
//    }
}

///// <#Description#>
//open class DBObject: DBObjectBase {
//
//    /// <#Description#>
//    ///
//    /// - id: <#id description#>
//    private enum CodingKeys : String, CodingKey {
//        case id = "_id"
//    }
//
//    /// <#Description#>
//    open var id: String  = UUID().uuidString
//
//    /// <#Description#>
//    public override init() { super.init() }
//
//    /// <#Description#>
//    ///
//    /// - Parameter decoder: <#decoder description#>
//    /// - Throws: <#throws value description#>
//    public required init(from decoder: Decoder) throws {
//        try super.init(from: decoder)
//
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(String.self, forKey: .id)
//    }
//
//
//    /// <#Description#>
//    ///
//    /// - Parameter encoder: <#encoder description#>
//    /// - Throws: <#throws value description#>
//    open override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//    }
//
//}


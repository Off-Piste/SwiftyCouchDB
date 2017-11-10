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
                    let object = try CodableUtils.decoder.decode(self, from: data)
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
            let newJSON = try CodableUtils.encoder.encodeJSON(object)
            
            db.update(object._id, with: newJSON, callback: callback)
        } catch {
            callback(.error(error))
        }
    }
    
    /// Method to be used when you wish to add an object to an array inside an Object but
    /// don't know the previous contents of the Array
    ///
    /// Using Swift 4's WritableKeyPath you can choose the path you wish to update when the
    /// object is retrieved
    ///
    /// - Parameters:
    ///   - change: <#change description#>
    ///   - keyPath: <#keyPath description#>
    ///   - callback: <#callback description#>
    public func addChange<Change: Codable, Sequence: RangeReplaceableCollection>(
        _ change: Change,
        forKeyPath keyPath: WritableKeyPath<Self, Sequence>,
        callback: @escaping (DBObjectChange, DBDocument) -> Void
        ) where Sequence.Element == Change
    {
        // 1. Retrieve the document
        guard let db = type(of: self).database else {
            callback(.error(createDBError(.invalidDatabase, reason: "Database is nil")), self)
            return
        }
        
        db.retrieve(self._id) { (info, error) in
            // Document does not exist
            // Create the document
            if let error = error as? AFError, error.responseCode == 404 {
                var newObject = self
                changeObject(change, in: &newObject, forKeyPath: keyPath)

                db.add(newObject, callback: { (info, error) in
                    if let error = error { callback(.error(error), self) }
                    else { callback(.addition, newObject) }
                })
            } else if let error = error {
                callback(.error(error), self)
            } else {
                do {
                    var oldObject = try JSONDecoder().decodeJSON(type(of: self), info!.json)
                    changeObject(change, in: &oldObject, forKeyPath: keyPath)

                    oldObject.update(callback: { (change) in
                        // If there are no changes then we can return self
                        // rather than `oldObject` (newObject)
                        switch change {
                        case .changes: callback(change, oldObject)
                        default: callback(change, self)
                        }
                    })
                } catch {
                    callback(.error(error), self)
                }
            }
        }
        
        // 2. Check the errors
        
        // 3. If
    }
}

// Move this outside as there was an error before :/
func changeObject<Change: Codable, Document: DBDocument, Sequence: RangeReplaceableCollection>(
    _ change: Change,
    in document: inout Document,
    forKeyPath keyPath: WritableKeyPath<Document, Sequence>
    ) where Sequence.Element == Change
{
    document[keyPath: keyPath].append(change)
}


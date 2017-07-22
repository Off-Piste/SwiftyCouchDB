import Foundation
import SwiftyJSON
import CouchDB

public struct DatabaseFile {
    
    public var name: String
    
}

public struct DatabaseDesign {
    
    public var name: String
    
}

public struct DatabaseSnapshot {
    
    public var id: String
    
    public var rev: String
    
    public var json: JSON
    
    internal var originalJSON: JSON
    
}

func createError(_ reason: String) -> Error {
    return NSError(domain: "db", code: -100, userInfo: [NSLocalizedDescriptionKey : reason]) as Error
}

func invalidJSONError(for type: Any, jsonType: Type) -> Error {
    return createError("The JSON node required the object [\(type)](\(type(of: type))) to be of type [\(jsonType)]")
}

public struct DatabaseReference : CustomStringConvertible {
    
    internal var database: Database, design: DatabaseDesign, file: DatabaseFile?, _children: [JSONSubscriptType] = []
    
    public var root: DatabaseReference {
        var root = DatabaseReference(ref: self)
        root._children.removeAll()
        return root
    }
    
    public var parent: DatabaseReference? {
        var parent = DatabaseReference(ref: self)
        
        if parent._children.isEmpty {
            return nil
        }
        
        parent._children.removeLast()
        return parent
    }
    
    internal init(database: Database, design: DatabaseDesign, file: DatabaseFile?) {
        self.database = database
        self.design = design
        self.file = file
    }
    
    private init(ref: DatabaseReference) {
        self.database = ref.database
        self.design = ref.design
        self.file = ref.file
        self._children = ref._children
    }
    
    public mutating func file(_ aFile: String) {
        self.file = DatabaseFile(name: aFile)
    }
    
    public mutating func child(_ path: JSONSubscriptType) -> DatabaseReference {
        self._children.append(path)
        return self
    }
    
    public mutating func childInArray(_ path: Int) -> DatabaseReference {
        return self.child(path)
    }
    
    public func retreive(callback: @escaping (DatabaseSnapshot?, Error?) -> Void) {
        if self.file == nil {
            callback(nil, createError("The Database file has not been set, if you are querying the data set please use query:"))
            return
        }
        
        self.database.retrieve(self.file!.name) { (json, error) in
            if let error = error {
                callback(nil, error)
            } else {
                let splitData = self.splitRetrive(json!)
                if self._children.count == 0 {
                    let snapshot = DatabaseSnapshot(id: splitData.id, rev: splitData.rev, json: splitData.json, originalJSON: json!)
                    callback(snapshot, nil)
                } else {
                    let callbackJSON: JSON = splitData.json[self._children]
                    
                    if let err = callbackJSON.error {
                        callback(nil, err)
                    } else {
                        let snapshot = DatabaseSnapshot(id: splitData.id, rev: splitData.rev, json: callbackJSON, originalJSON: json!)
                        callback(snapshot, nil)
                    }
                }
            }
        }
    }
    
    public func update(_ value: Any) {
        self.updateChildValue(value) { (_, err) in }
    }
    
    public func removeValue() {
        self.removeChildValue { (_, err) in }
    }
    
    public func removeChildValue(callback: @escaping (DatabaseReference, Error?) -> Void) {
        self.updateChildValue(nil, callback: callback)
    }
    
    public func updateChildValue(_ value: Any?, callback: @escaping (DatabaseReference, Error?) -> Void) {
        if self.file == nil {
            callback(self, createError("The Database file has not been set, if you are querying the data set please use query:"))
            return
        }
        
        self.database.retrieve(self.file!.name) { (json, error) in
            if let error = error {
                callback(self, error)
            } else {
                let touple = self.splitRetrive(json!)
                var json = touple.json
                do {
                    try self.updateJSON(&json, withValue: value)
                    if json.error != nil {
                        throw json.error!
                    }
                    
                    self.database.update(
                        self.file!.name,
                        rev: touple.rev,
                        document: json,
                        callback: { (_, json, error) in
                            NSLog(json?.rawString() ?? "")
                            callback(self, error)
                    }
                    )
                } catch {
                    callback(self, error)
                }
            }
            
        }
    }
    
    public func queryByView(_ view: String, using parameters: [Database.QueryParameters], callback: @escaping (JSON?, NSError?) -> Void) {
        self.database.queryByView(view, ofDesign: self.design.name, usingParameters: parameters) { (json, error) in
            if let error = error {
                callback(nil, error)
            } else {
                if self._children.count == 0 {
                    callback(json!, nil)
                } else {
                    let callbackJSON: JSON = json![self._children]
                    if callbackJSON.error != nil {
                        callback(nil, callbackJSON.error)
                    } else {
                        callback(callbackJSON, nil)
                    }
                }
            }
        }
    }
    
    public var description: String {
        var objects = [String?]()
        objects.append("Database: \(database.name)")
        objects.append(file != nil ? "File: \(file!.name)" : nil)
        objects.append("Design: \(design.name)")
        objects.append(_children.count > 0 ? "Children: [\(self._children.map { "\($0)" }.joined(separator: ", "))]" : nil)
        objects.append(_children.last == nil ? nil : "Current Child: \(_children.last ?? "None")")
        return "DatabaseReference { \(objects.flatMap { $0 }.joined(separator: " | ")) }"
    }
    
}

fileprivate extension DatabaseReference {
    
    func removeValue(inJSON json: inout JSON) throws {
        let jsonType: Type
        if _children.count == 0 {
            jsonType = json.type
        } else {
            jsonType = json[_children].type
        }
        
        switch jsonType {
        case .array:
            if _children.count == 0 {
                json.arrayObject = nil
            } else {
                json[_children].arrayObject?.remove(at: self._children.last! as! Int)
            }
        case .unknown:
            throw createError("Unknown JSON type")
        default:
            if _children.count == 0 {
                json.object = NSNull()
            } else {
                json[_children].object = NSNull()
            }
        }
    }
    
    func updateJSON(_ json: inout JSON, withValue value: Any?) throws {
        let jsonType: Type
        if _children.count == 0 {
            jsonType = json.type
        } else {
            jsonType = json[_children].type
        }
        
        guard let value = value else {
            try self.removeValue(inJSON: &json)
            return
        }
        
        switch jsonType {
        case .dictionary:
            if !(value is [String : Any]) {
                throw invalidJSONError(for: value, jsonType: jsonType)
            }
            
            if _children.count == 0 {
                json.dictionaryObject = (value as! [String : Any])
            } else {
                json[_children].dictionaryObject = (value as! [String : Any])
            }
        case .array:
            if !(value is Array<Any>) {
                throw invalidJSONError(for: value, jsonType: jsonType)
            }
            
            if _children.count == 0 {
                json.arrayObject?.append(contentsOf: (value as! Array<Any>))
            } else {
                json[_children].arrayObject?.append(contentsOf: (value as! Array<Any>))
            }
        case .string:
            if !(value is String) {
                throw invalidJSONError(for: value, jsonType: jsonType)
            }
            
            if _children.count == 0 {
                json.string = (value as! String)
            } else {
                json[_children].string = (value as! String)
            }
        case .number:
            if !(value is NSNumber) {
                throw invalidJSONError(for: value, jsonType: jsonType)
            }
            
            if _children.count == 0 {
                json.number = (value as! NSNumber)
            } else {
                json[_children].number = (value as! NSNumber)
            }
        case .bool:
            if !(value is Bool) {
                throw invalidJSONError(for: value, jsonType: jsonType)
            }
            
            if _children.count == 0 {
                json.bool = (value as! Bool)
            } else {
                json[_children].bool = (value as! Bool)
            }
        case .null:
            if _children.count == 0 {
                json.object = value
            } else {
                json[_children].object = value
            }
        default:
            throw createError("Unknown JSON type")
        }
    }
    
    func splitRetrive(_ data: JSON) -> (id: String, rev: String, json: JSON) {
        let id = data["_id"].stringValue
        let rev = data["_rev"].stringValue
        let json = data
        return (id, rev, json)
    }
    
}

public struct DatabaseManager {
    
    public var reference: DatabaseReference
    
    public init(database: Database, design: String) {
        let design = DatabaseDesign(name: design)
        self.reference = DatabaseReference(database: database, design: design, file: nil)
    }
    
    public init(database: Database, design: String, file: String) {
        let design = DatabaseDesign(name: design)
        let file = DatabaseFile(name: file)
        self.reference = DatabaseReference(database: database, design: design, file: file)
    }
    
    public func referenceForFile(_ aFile: String) -> DatabaseReference {
        let file = DatabaseFile(name: aFile)
        return DatabaseReference(database: reference.database, design: reference.design, file: file)
    }
    
}

// import Foundation
// import LoggerAPI
// @_exported import SwiftyJSON
// @_exported import CouchDB
//
// public struct ____DatabaseReference {
//
//     internal var client: CouchDBClient
//
//     internal var database: Database
//
//     internal var design: DatabaseDesign
//
//     internal var file: DatabaseFile?
//
//     internal var _children: [JSONSubscriptType] = []
//
//     public var root: __DatabaseReference {
//         var root = __DatabaseReference(ref: self)
//         root._children.removeAll()
//         return root
//     }
//
//     public var parent: __DatabaseReference? {
//         var parent = __DatabaseReference(ref: self)
//         if parent._children.isEmpty {
//             return nil
//         } else {
//             parent._children.removeLast()
//             return parent
//         }
//     }
//
//     internal init(
//         client: CouchDBClient,
//         db: Database,
//         design: DatabaseDesign,
//         file: DatabaseFile?
//         ) // swiftlint:disable opening_brace
//     {
//         self.client = client
//         self.database = db
//         self.design = design
//         self.file = file
//     }
//
//     internal init(
//         client: CouchDBClient,
//         dbName: String,
//         design: DatabaseDesign,
//         file: DatabaseFile?
//         ) // swiftlint:disable:this opening_brace
//     {
//         self.client = client
//         self.database = client.database(dbName)
//         self.design = design
//         self.file = file
//     }
//
//     fileprivate init(ref: __DatabaseReference) {
//         self.init(client: ref.client, db: ref.database, design: ref.design, file: ref.file)
//     }
//
//     public func retreive(callback: @escaping (DatabaseSnapshot?, Error?) -> Void) {
//         if self.file == nil {
//             let msg = "The Database file has not been set, if you are querying the data set please use `queryByView:`"
//             callback(nil, createError(msg))
//             return
//         }
//
//         self.database.retrieve(self.file!.name) { (json, error) in
//             if let error = error {
//                 callback(nil, error)
//             } else {
//                 let splitData = self.splitRetrive(json!)
//                 let id = splitData.id
//                 let rev = splitData.rev
//                 let json_data = splitData.json
//
//                 if self._children.isEmpty {
//                     let snapshot = DatabaseSnapshot(id: id, rev: rev, json: json_data, originalJSON: json!)
//                     callback(snapshot, nil)
//                 } else {
//                     let callbackJSON: JSON = json_data[self._children]
//
//                     if let err = callbackJSON.error {
//                         callback(nil, err)
//                     } else {
//                         let snapshot = DatabaseSnapshot(id: id, rev: rev, json: json_data, originalJSON: json!)
//                         callback(snapshot, nil)
//                     }
//                 }
//             }
//         }
//     }
//
//     public func queryByView(
//         _ view: String,
//         using parameters: [Database.QueryParameters],
//         callback: @escaping (JSON?, NSError?) -> Void
//         ) // swiftlint:disable:this opening_brace
//     {
//         self.database.queryByView(view, ofDesign: self.design.name, usingParameters: parameters) { (json, error) in
//             if let error = error {
//                 callback(nil, error)
//             } else {
//                 if self._children.isEmpty {
//                     callback(json!, nil)
//                 } else {
//                     let callbackJSON: JSON = json![self._children]
//                     if callbackJSON.error != nil {
//                         callback(nil, callbackJSON.error)
//                     } else {
//                         callback(callbackJSON, nil)
//                     }
//                 }
//             }
//         }
//     }
// }
//
// // MARK: - File Creation
// public extension __DatabaseReference {
//
//     public func createFile(callback: @escaping CouchDBSnapshot) {
//         self.createFile(nil, withJSON: ["data": [:]], callback: callback)
//     }
//
//     public func createFile(_ name: String, callback: @escaping CouchDBSnapshot) {
//         self.createFile(name, withJSON: ["data": [:]], callback: callback)
//     }
//
//     public func createFile(withJSON json: JSON, callback: @escaping CouchDBSnapshot) {
//         self.createFile(nil, withJSON: json, callback: callback)
//     }
//
//     public func createFile(
//         _ name: String?,
//         withJSON json: JSON,
//         callback: @escaping CouchDBSnapshot
//         ) // swiftlint:disable:this opening_brace
//     {
//         if let error = self.validateDatabase_Creation() { callback(nil, error) }
//         var document = json
//         if name != nil {
//             document["_id"].string = name!
//         } else if self.file?.name != nil {
//             document["_id"].string = self.file?.name
//         } else {
//             Log.info("No name has been set so the file will be created with a default id")
//         }
//
//         self.database.create(document) { (id, rev, json, error) in
//             if let error = error {
//                 callback(nil, error)
//             } else {
//                 let snapshot = DatabaseSnapshot(id: id!, rev: rev!, json: json!)
//                 callback(snapshot, nil)
//             }
//         }
//     }
//
//     private func validateDatabase_Creation() -> Error? {
//         if self.database is UsersDatabase {
//             let msg = "When creating a file for UsersDatabase, please use `:`"
//             return createError(msg)
//         }
//         return nil
//     }
//
// }
//
// public extension __DatabaseReference {
//
//     public func createUser(
//         withName name: String,
//         email: String,
//         password: String,
//         callback: @escaping (DatabaseSnapshot?, Error?) -> Void
//         ) // swiftlint:disable:this opening_brace
//     {
//         let json: JSON = [
//             "name" : name,
//             "email" : email,
//             "password" : password,
//             "type" : "user",
//             "roles" : [
//             ]
//         ]
//
//         self.createUser(withJSON: json, callback: callback)
//     }
//
//     public func createUser(
//         withJSON json: JSON,
//         callback: @escaping (DatabaseSnapshot?, Error?) -> Void
//         ) // swiftlint:disable:this opening_brace
//     {
//         if let err = self.validateUserDatabase_Creation() {
//             callback(nil, err)
//         } else {
//             guard let userDB = self.database as? UsersDatabase else {
//                 fatalError("In the case this is hit, `validateUserDatabase_Creation()` failed")
//             }
//
//             userDB.createUser( document: json, callback: { (id, document, error) in
//                 if let error = error {
//                     callback(nil, error)
//                 } else {
//                     guard let json = document, let rev = json["rev"].string, let id = id else {
//                         let error = createError("Could not parse JSON [\(String(describing: document?.rawValue))]")
//                         callback(nil, error)
//                         return
//                     }
//
//                     let snapshot = DatabaseSnapshot(id: id, rev: rev, json: json)
//                     callback(snapshot, nil)
//                 }
//             })
//         }
//     }
//
//     public func deleteUser(_ id: String, callback: @escaping (Error?) -> Void) {
//         if let error = self.validateUserDatabase_Creation() {
//             callback(error)
//         } else {
//             var currentRef = __DatabaseReference(ref: self)
//             currentRef.file(id)
//             currentRef._children.removeAll()
//             currentRef.retreive(callback: { (snapshot, error) in
//                 if let error = error {
//                     callback(error)
//                 } else {
//                     let id = snapshot!.id
//                     let rev = snapshot!.rev
//                     currentRef.database.delete(id, rev: rev, callback: callback)
//                 }
//             })
//         }
//     }
//
//     private func validateUserDatabase_Creation() -> Error? {
//         if !(self.database is UsersDatabase) {
//             let msg = "When creating a file for a normal database, please use `:`"
//             return createError(msg)
//         }
//         return nil
//     }
// }
//
// // MARK: - Mutating Methods
// public extension __DatabaseReference {
//
//     public mutating func file(_ aFile: String) {
//         self.file = DatabaseFile(name: aFile)
//     }
//
//     public mutating func child(_ path: JSONSubscriptType) -> __DatabaseReference {
//         self._children.append(path)
//         return self
//     }
//
//     public mutating func childInArray(_ path: Int) -> __DatabaseReference {
//         return self.child(path)
//     }
//
// }
//
// // MARK: - JSON Mutation
// public extension __DatabaseReference {
//
//     public func update(_ value: Any) {
//         self.updateChildValue(value) { (_, err) in
//             guard let error = err else { return }
//             Log.error(error.localizedDescription)
//         }
//     }
//
//     public func removeValue() {
//         self.removeValue { (_, err) in
//             guard let error = err else { return }
//             Log.error(error.localizedDescription)
//         }
//     }
//
//     public func removeValue(callback: @escaping (__DatabaseReference, Error?) -> Void) {
//         self.updateChildValue(nil, callback: callback)
//     }
//
//     public func updateChildValue(
//         _ value: Any?,
//         callback: @escaping (__DatabaseReference, Error?) -> Void
//         ) // swiftlint:disable opening_brace
//     {
//         if self.file == nil {
//             let msg = "The Database file has not been set"
//             callback(self, createError(msg))
//             return
//         }
//
//         self.database.retrieve(self.file!.name) { (json, error) in
//             if let error = error {
//                 callback(self, error)
//             } else {
//                 let touple = self.splitRetrive(json!)
//                 var json = touple.json
//                 do {
//                     try self.updateJSON(&json, withValue: value)
//                     if json.error != nil {
//                         throw json.error!
//                     }
//
//                     self.database.update(
//                         self.file!.name,
//                         rev: touple.rev,
//                         document: json,
//                         callback: { (_, json, error) in
//                             NSLog(json?.rawString() ?? "")
//                             callback(self, error)
//                         }
//                     )
//                 } catch {
//                     callback(self, error)
//                 }
//             }
//         }
//     }
// }
//
// // MARK: - Client Methods
// public extension __DatabaseReference {
//
//     public func exists(callback: @escaping (Bool, NSError?) -> Void) {
//         self.client.dbExists(self.database.name, callback: callback)
//     }
//
//     public func createDatabase(callback: @escaping (NSError?) -> Void) {
//         self.client.createDB(self.database.name) { (_, err) in callback(err) }
//     }
//
//     public func deleteDatabase(callback: @escaping (NSError?) -> Void) {
//         self.client.deleteDB(self.database, callback: callback)
//     }
//
// }
//
// extension __DatabaseReference : CustomStringConvertible {
//
//     public var description: String {
//         var objects = [String?]()
//
//         // swiftlint:disable line_length
//         objects.append("Database: \(database.name)")
//         objects.append(file != nil ? "File: \(file!.name)" : nil)
//         objects.append("Design: \(design.name)")
//         objects.append(!_children.isEmpty ? "Children: [\(self._children.map { "\($0)" }.joined(separator: ", "))]" : nil)
//         objects.append(_children.last == nil ? nil : "Current Child: \(_children.last ?? "None")")
//         return "__DatabaseReference { \(objects.flatMap { $0 }.joined(separator: " | ")) }"
//     }
//
// }
//
// // MARK: - Private JSON methods
// fileprivate extension __DatabaseReference {
//
//     func removeValue(inJSON json: inout JSON) throws {
//         let jsonType: Type
//         if _children.isEmpty {
//             jsonType = json.type
//         } else {
//             jsonType = json[_children].type
//         }
//
//         switch jsonType {
//         case .array:
//             if _children.isEmpty {
//                 json.arrayObject = nil
//             } else {
//                 guard let index = self._children.last as? Int else {
//                     throw createError("Invalid Child")
//                 }
//
//                 json[_children].arrayObject?.remove(at: index)
//             }
//         case .unknown:
//             throw createError("Unknown JSON type")
//         default:
//             if _children.isEmpty {
//                 json.object = NSNull()
//             } else {
//                 json[_children].object = NSNull()
//             }
//         }
//     }
//
//     func updateJSON(_ json: inout JSON, withValue value: Any?) throws {
//         let jsonType: Type
//         if _children.isEmpty {
//             jsonType = json.type
//         } else {
//             jsonType = json[_children].type
//         }
//
//         guard let value = value else {
//             try self.removeValue(inJSON: &json)
//             return
//         }
//
//         switch jsonType {
//         case .dictionary:
//             try self.updateDictionary(value, for: &json)
//         case .array:
//             try self.updateArray(value, for: &json)
//         case .string:
//             try self.updateString(value, for: &json)
//         case .number:
//             try self.updateNumber(value, for: &json)
//         case .bool:
//             try self.updateBool(value, for: &json)
//         case .null:
//             try self.updateNull(value, for: &json)
//         default:
//             throw createError("Unknown JSON type")
//         }
//     }
//
//     func updateString(_ value: Any, for json: inout JSON) throws {
//         let jsonType: Type = .string
//
//         guard let string = value as? String else {
//             throw invalidJSONError(for: value, jsonType: jsonType)
//         }
//
//         if _children.isEmpty {
//             json.string = string
//         } else {
//             json[_children].string = string
//         }
//     }
//
//     func updateNumber(_ value: Any, for json: inout JSON) throws {
//         let jsonType: Type = .number
//
//         guard let number = value as? NSNumber else {
//             throw invalidJSONError(for: value, jsonType: jsonType)
//         }
//
//         if _children.isEmpty {
//             json.number = number
//         } else {
//             json[_children].number = number
//         }
//     }
//
//     func updateArray(_ value: Any, for json: inout JSON) throws {
//         let jsonType: Type = .array
//
//         guard let array = value as? [Any] else {
//             throw invalidJSONError(for: value, jsonType: jsonType)
//         }
//
//         if _children.isEmpty {
//             json.arrayObject?.append(contentsOf: array)
//         } else {
//             json[_children].arrayObject?.append(contentsOf: array)
//         }
//     }
//
//     func updateNull(_ value: Any, for json: inout JSON) throws {
//         if _children.isEmpty {
//             json.object = value
//         } else {
//             json[_children].object = value
//         }
//     }
//
//     func updateBool(_ value: Any, for json: inout JSON) throws {
//         let jsonType: Type = .bool
//
//         guard let bool = value as? Bool else {
//             throw invalidJSONError(for: value, jsonType: jsonType)
//         }
//
//         if _children.isEmpty {
//             json.bool = bool
//         } else {
//             json[_children].bool = bool
//         }
//     }
//
//     func updateDictionary(_ value: Any, for json: inout JSON) throws {
//         let jsonType: Type = .dictionary
//
//         guard let dict = value as? [String : Any] else {
//             throw invalidJSONError(for: value, jsonType: jsonType)
//         }
//
//         if _children.isEmpty {
//             json.dictionaryObject = dict
//         } else {
//             json[_children].dictionaryObject = dict
//         }
//
//     }
//
//     func splitRetrive(_ data: JSON) -> (id: String, rev: String, json: JSON) {
//         let id = data["_id"].stringValue
//         let rev = data["_rev"].stringValue
//         let json = data
//         return (id, rev, json)
//     }
// }

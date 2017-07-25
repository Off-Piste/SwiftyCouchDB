//
//  DatabaseReference.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 25.07.17.
//
//

import Foundation
import SwiftyJSON
import CouchDB

public struct DatabaseReference<Manager: DBManager> {

    internal var db: Database

    internal var design: String

    internal var file: String?

    internal var _children: [JSONSubscriptType] = []

    public var root: DatabaseReference {
        var root = DatabaseReference(ref: self)
        root._children.removeAll()
        return root
    }

    public var parent: DatabaseReference? {
        var parent = DatabaseReference(ref: self)
        if parent._children.isEmpty {
            return nil
        } else {
            parent._children.removeLast()
            return parent
        }
    }

    init(db: Database, design: String) {
        self.db = db
        self.design = design
    }

    init(ref: DatabaseReference) {
        self.db = ref.db
        self.design = ref.design
        self.file = ref.file
        self._children = ref._children
    }

    public mutating func file(_ aFile: String) {
        self.file = aFile
    }
    
}

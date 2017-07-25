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

    fileprivate var db: Database

    fileprivate var design: String?

    fileprivate var file: String?

    fileprivate var children: [JSONSubscriptType] = []

    public var child: JSONSubscriptType? {
        return children.last
    }

    public var parent: DatabaseReference? {
        var parent = DatabaseReference(ref: self)
        if parent.children.isEmpty {
            return nil
        } else {
            parent.children.removeLast()
            return parent
        }
    }

    public var root: DatabaseReference {
        var root = DatabaseReference(ref: self)
        root.children.removeAll()
        return root
    }

    init(db: Database, design: String?) {
        self.db = db
        self.design = design
    }

    init(ref: DatabaseReference) {
        self.db = ref.db
        self.design = ref.design
        self.file = ref.file
        self.children = ref.children
    }
}

extension DatabaseReference {

    subscript(child aChild: JSONSubscriptType) -> DatabaseReference {
        mutating get {
            return self.child(aChild)
        }
    }

    public mutating func design(_ aDesign: String) {
        self.design = aDesign
    }

    public mutating func file(_ aFile: String) {
        self.file = aFile
    }

    public mutating func child(_ aChild: JSONSubscriptType) -> DatabaseReference {
        self.children.append(aChild)
        return self
    }
}

extension DatabaseReference where Manager == CouchDatabase {
}

extension DatabaseReference where Manager == CouchAuth {

    func createUser() {
    }
}

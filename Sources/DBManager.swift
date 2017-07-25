//
//  DBManager.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 25.07.17.
//
//

import Foundation

public protocol DBManager {

    var reference: DatabaseReference<Self> { get }

    func referenceForFile(_ aFile: String) -> DatabaseReference<Self>

}

extension DBManager {

    public func referenceForFile(_ aFile: String) -> DatabaseReference<Self> {
        var aRef = DatabaseReference(ref: reference)
        aRef.file(aFile)
        return aRef
    }
    
}

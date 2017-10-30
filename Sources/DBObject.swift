//
//  DBObject.swift
//  CouchDB
//
//  Created by Harry Wright on 22.10.17.
//  Copyright © 2017 Trolley. All rights reserved.
//

import Foundation

/// <#Description#>
public struct DBObjectChanges { }

/// <#Description#>
open class DBObject: DBObjectBase {

    /// <#Description#>
    ///
    /// - id: <#id description#>
    private enum CodingKeys : String, CodingKey {
        case id = "_id"
    }

    /// <#Description#>
    open var id: String  = UUID().uuidString

    /// <#Description#>
    public required override init() { super.init() }

    /// <#Description#>
    ///
    /// - Parameter decoder: <#decoder description#>
    /// - Throws: <#throws value description#>
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
    }


    /// <#Description#>
    ///
    /// - Parameter encoder: <#encoder description#>
    /// - Throws: <#throws value description#>
    open override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }

}


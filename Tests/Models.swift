//
//  Models.swift
//  SwiftyCouchDBTests
//
//  Created by Harry Wright on 30.10.17.
//

import Foundation
import SwiftyCouchDB

enum UserKeys: String, CodingKey {
    case username
    case email
}

class User: DBObject {

    typealias Keys = UserKeys

    var username: String = ""

    var email: String = ""

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)

        let container = try decoder.container(keyedBy: Keys.self)
        self.username = try container.decode(String.self, forKey: .username)
        self.email = try container.decode(String.self, forKey: .email)
    }

    required init() { super.init() }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
    }

}

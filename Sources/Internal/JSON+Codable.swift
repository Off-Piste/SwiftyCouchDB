//
//  JSON+Codable.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 10.11.17.
//

import Foundation
import SwiftyJSON

extension JSON {
    init<C: Codable>(codable: C) {
        do {
            let data = try Utils.encoder.encode(codable)
            self.init(data: data)
        } catch {
            self.init(NSNull())
        }
    }
}

extension JSONEncoder {
    func encodeJSON<E: Encodable>(_ object: E) throws -> JSON {
        let data = try self.encode(object)
        return JSON(data: data)
    }
}

extension JSONDecoder {
    func decodeJSON<D: Decodable>(_ object: D.Type, _ json: JSON) throws -> D {
        let data = try json.rawData()
        return try self.decode(object, from: data)
    }
}

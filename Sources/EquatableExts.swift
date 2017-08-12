//
//  EquatableExts.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 09.08.17.
//
//

import Foundation
import SwiftyJSON

extension Optional where Wrapped: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Optional, rhs: Optional) -> Bool {
        switch (lhs, rhs) {
        case let (.some(W1), .some(W2)): return W1 == W2
        case (.none, .none): return true
        case (.none, _), (.some, _): return false
        }
    }
}

public func == (lhs: JSONSubscriptType, rhs: JSONSubscriptType) -> Bool {
    switch (lhs.jsonKey, rhs.jsonKey) {
    case let (.index(index1), .index(index2)): return index1 == index2
    case let (.key(key1), .key(key2)): return key1 == key2
    case (.key, _), (.index, _): return false
    }
}

public func == (lhs: JSONSubscriptType?, rhs: JSONSubscriptType?) -> Bool {
    switch (lhs, rhs) {
    case let (.some(W1), .some(W2)): return W1 == W2
    case (.none, .none): return true
    case (.none, _), (.some, _): return false
    }
}

public func == (lhs: [JSONSubscriptType], rhs: [JSONSubscriptType]) -> Bool {
    return (lhs as NSArray).isEqual(to: rhs)
}

//extension Array : Equatable {
//
//    /// Returns a Boolean value indicating whether two values are equal.
//    ///
//    /// Equality is the inverse of inequality. For any values `a` and `b`,
//    /// `a == b` implies that `a != b` is `false`.
//    ///
//    /// - Parameters:
//    ///   - lhs: A value to compare.
//    ///   - rhs: Another value to compare.
//    public static func == (lhs: Array, rhs: Array) -> Bool {
//        return (lhs as NSArray).isEqual(to: rhs)
//    }
//}

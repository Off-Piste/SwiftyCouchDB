//
//  String+Regex.swift
//  CouchDB
//
//  Created by Harry Wright on 23.10.17.
//  Copyright © 2017 Trolley. All rights reserved.
//

import Foundation

extension String {

    var nsRange: NSRange {
        return NSRange(location: 0, length: utf16.count)
    }

    func doesMatch(
        _ patern: String,
        options: NSRegularExpression.MatchingOptions = .anchored
        ) -> Bool
    {
        guard let regex = try? NSRegularExpression(pattern: patern) else { return false }
        if regex.firstMatch(in: self, options: options, range: nsRange) != nil {
            return true
        }
        return false
    }

    func matches(
        _ patern: String,
        options: NSRegularExpression.MatchingOptions = .anchored
        ) -> [String]
    {
        guard let regex = try? NSRegularExpression(pattern: patern) else { return [] }
        return regex.matches(in: self, options: options, range: nsRange).map {
            let range = Range($0.range, in: self)!
            return String(self[range])
        }
    }
}

extension URL: ExpressibleByStringLiteral {

    /// A type that represents a string literal.
    public typealias StringLiteralType = String

    /// Creates an instance initialized to the given string value.
    ///
    /// - Parameter value: The value of the new instance.
    public init(stringLiteral value: StringLiteralType) {
        self.init(string: value)!
    }
    
}

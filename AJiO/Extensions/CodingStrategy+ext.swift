//
//  CodingStrategy+ext.swift
//  AJiO
//
//  Created by Maksymilian Stan on 21/05/2024.
//

import Foundation

extension JSONDecoder.KeyDecodingStrategy {
    static var convertFromKebabCase: JSONDecoder.KeyDecodingStrategy {
        return .custom { keys in
            let lastKey = keys.last!
            if lastKey.intValue != nil {
                return lastKey
            }
            let key = lastKey.stringValue
            let camelCasedKey = key.split(separator: "-")
                .enumerated()
                .map { index, part in
                    if index == 0 {
                        return part.lowercased()
                    } else {
                        return part.capitalized
                    }
                }
                .joined()
            return AnyKey(stringValue: camelCasedKey) ?? lastKey
        }
    }
}

private struct AnyKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}

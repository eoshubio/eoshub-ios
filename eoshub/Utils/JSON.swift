//
//  JSON.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 13..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

protocol JSONInitializable {
    init?(json: JSON)
}

protocol JSONOutput {
    var json: JSON { get }
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    
    static func createJSON(from jsonString: String) -> JSON? {
        
        if let data = jsonString.data(using: .utf8),
            let decoded = try? JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                return decoded
        }
        return nil
    }
    
    var stringValue: String? {
        
        if let jsonData =  try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
            let string = String(data: jsonData, encoding: .utf8) {
            return string
        }
        return nil
    }
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    func parseValue<T>(for key: Key) -> T? {
        if let value = self[key] as? T {
            return value
        }
        return nil
    }
    
    func json(for key: Key) -> JSON? {
        let value: JSON? = parseValue(for: key)
        return value
    }
    
    func object(for key: Key) -> AnyObject? {
        let value: AnyObject? = parseValue(for: key)
        return value
    }
    
    func string(for key: Key) -> String? {
        let value: String? = parseValue(for: key)
        return value
    }
    
    func doubleOrString(for key: Key) -> String? {
        if let value: Double = parseValue(for: key) {
            return String(format: "%.0f", value)
        } else {
            return parseValue(for: key)
        }
    }
    
    func integer(for key: Key) -> Int? {
        let value: Int? = parseValue(for: key)
        if let stringValue = string(for: key) {
            return Int(stringValue)
        }
        return value
    }
    
    func integer32(for key: Key) -> Int32? {
        let value: Int32? = parseValue(for: key)
        if let stringValue = string(for: key) {
            return Int32(stringValue)
        }
        return value
    }
    
    func integer64(for key: Key) -> Int64? {
        let value: Int64? = parseValue(for: key)
        if let stringValue = string(for: key) {
            return Int64(stringValue)
        }
        return value
    }
    
    func float(for key: Key) -> Float? {
        let value: Float? = parseValue(for: key)
        if let stringValue = string(for: key) {
            return Float(stringValue)
        }
        return value
    }
    
    func double(for key: Key) -> Double? {
        let value: Double? = parseValue(for: key)
        if let stringValue = string(for: key) {
            return Double(stringValue)
        }
        return value
    }
    
    func bool(for key: Key) -> Bool? {
        let value: Bool? = parseValue(for: key)
        if let stringValue = string(for: key) {
            return Bool(stringValue)
        }
        return value
    }
    
    func arrayJson(for key: Key) -> [JSON]? {
        let value: [JSON]? = parseValue(for: key)
        return value
    }
    
    func arrayString(for key: Key) -> [String]? {
        let value: [String]? = parseValue(for: key)
        return value
    }
}

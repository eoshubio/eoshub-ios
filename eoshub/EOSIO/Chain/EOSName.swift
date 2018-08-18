//
//  EOSName.swift
//  eosio-api
//
//  Created by kein on 2018. 7. 3..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation


class EOSName: Packable, Equatable {
    static func == (lhs: EOSName, rhs: EOSName) -> Bool {
        return lhs.value == rhs.value
    }
    
    private let MAX_NAME_IDX = 12
    
    var value: String = ""
    
    init(_ string: String) {
        if string.count > MAX_NAME_IDX {
            preconditionFailure("account name is too long: \(string.count) / 12")
        }
        
        value = string
    }
    
    
    
    fileprivate func stringToUInt64(string: String) -> UInt64 {
        if string.isEmpty {
            return 0
        }
        let name = Array(string)
        let len = string.count
        var value: UInt64 = 0
        
        for i in 0...MAX_NAME_IDX {
            var c: UInt64 = 0
            if i < len && i <= MAX_NAME_IDX {
                c = UInt64(charToSymbol(name[i]))
            }
            if i < MAX_NAME_IDX {
                c &= 0x1f
                c <<= 64 - 5 * (i + 1)
            } else {
                c &= 0x0f
            }
            value |= c
        }
        return value
    }
    
    fileprivate func charToSymbol(_ chr: Character) -> UInt8 {
        let c = chr.unicode
        if c >= "a".unicode && c <= "z".unicode {
            return UInt8((c - "a".unicode) + 6)
        }
        
        if c >= "1".unicode && c <= "5".unicode {
            return UInt8((c - "1".unicode) + 1)
        }
        
        return 0
    }
    
    //MARK: Packable
    
    @discardableResult func serialize(pack: Pack) -> Pack {
        pack.putInt64(value: stringToUInt64(string: value))
        return pack
    }
    
    
}



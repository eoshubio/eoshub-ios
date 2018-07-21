//
//  Validator.swift
//  eoshub
//
//  Created by kein on 2018. 7. 19..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

struct Validator {
    fileprivate static let validChars = Array(".12345abcdefghijklmnopqrstuvwxyz")
    fileprivate static let maxLength = 12
    
    static func accountName(name: String) -> Bool {
        if name.count == 0 {
            return false
        }

        for chr in name {
            if validChars.contains(chr) == false {
                return false
            }
        }
        
        return true
    }
    
    static func wrongAccountName(name: String) -> [NSRange] {
        if name.count == 0 {
            return []
        }

        var indices: [Int] = []
        
        var iterator = 0
        for chr in name {
            if validChars.contains(chr) == false || iterator > maxLength {
                indices.append(iterator)
            }
            iterator += 1
        }
        
        
        return indices.map { NSMakeRange($0, 1) }
    }
    
    
    
}

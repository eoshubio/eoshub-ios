//
//  Validator.swift
//  eoshub
//
//  Created by kein on 2018. 7. 19..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

struct Validator {
    
    static func accountName(name: String) -> Bool {
        //for create account
        let validChars = Array(".12345abcdefghijklmnopqrstuvwxyz")
        
        for chr in name {
            if validChars.contains(chr) == false {
                return false
            }
        }
        
        return true
    }
    
    
    
    
}

//
//  Character+extension.swift
//  eosio-api
//
//  Created by kein on 2018. 7. 3..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

extension Character {
    
    var unicode: UInt32 {
        let scalars = String(self).unicodeScalars
        return scalars[scalars.startIndex].value
    }
}

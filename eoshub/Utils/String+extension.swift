//
//  String+extension.swift
//  eosio-api
//
//  Created by kein on 2018. 7. 3..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

//MARK: Unicode conversion
extension String {
    
    var unicode: UInt32 {
        let scalars = unicodeScalars
        return scalars[scalars.startIndex].value
    }
}

//MARK: Range
extension StringProtocol where Index == String.Index {
    func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}

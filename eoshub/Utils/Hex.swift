//
//  Hex.swift
//  eosio-api
//
//  Created by kein on 2018. 7. 4..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation


extension String {
    
    var hex: String {
        let data = Data(self.utf8)
        let h = data.map { String(format: "%02x", $0)}.joined()
        return h
    }
    
    var hexToBytes: [UInt8] {
        var dst = [UInt8]()
        var hex: [UInt8] = self.utf8.map { UInt8($0) }
        
        for i in 0..<count where i%2 == 0 {
            let c = (hex[i] % 32 + 9) % 25 * 16 + (hex[i+1] % 32 + 9) % 25
            dst.append(c)
        }
        return dst
    }
    
}


extension RangeReplaceableCollection where Iterator.Element == UInt8 {
    var hex: String {
        let bytes = self as! [UInt8]
        let data = Data(bytes: bytes)
        let h = data.map { String(format: "%02x", $0)}.joined()
        return h
    }
    
}

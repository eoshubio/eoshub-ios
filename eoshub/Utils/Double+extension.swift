//
//  Double+extension.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

extension Double {
    
    var dot4String: String {
        return String(format: "%.04f", self)
    }
    
    var dot2String: String {
        return String(format: "%.04f", self)
    }
    
    var f: Float {
        return Float(self)
    }
    
    func getString(precision: Int) -> String {
        switch precision {
        case 0:
            return String(format: "%d", Int(self))
        case 1:
            return String(format: "%.01f", self)
        case 2:
            return String(format: "%.02f", self)
        case 3:
            return String(format: "%.03f", self)
        case 4:
            return String(format: "%.04f", self)
        case 5:
            return String(format: "%.05f", self)
        case 6:
            return String(format: "%.06f", self)
        case 7:
            return String(format: "%.07f", self)
        case 8:
            return String(format: "%.08f", self)
        default:
            return String(format: "%.04f", self)
        }
    }
}

extension Int64 {
    var doubleValue: Double {
        return Double(self)
    }
}

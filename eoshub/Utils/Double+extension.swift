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
            return String(format: "%d", Int(precision))
        case 1:
            return String(format: "%.01f", precision)
        case 2:
            return String(format: "%.02f", precision)
        case 3:
            return String(format: "%.03f", precision)
        case 4:
            return String(format: "%.04f", precision)
        case 5:
            return String(format: "%.05f", precision)
        case 6:
            return String(format: "%.06f", precision)
        case 7:
            return String(format: "%.07f", precision)
        case 8:
            return String(format: "%.08f", precision)
        default:
            return String(format: "%.04f", precision)
        }
    }
}

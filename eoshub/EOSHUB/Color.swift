//
//  Color.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

enum Color {
    case basePurple, baseGray
    case darkGray, gray, lightGray
    case lightPurple
    case red, green, blue
    case seperator
    case clear
    
    var uiColor: UIColor {
        switch self {
        case .basePurple:
            return UIColor.colorUInt8(r: 83, g: 32, b: 173)
        case .darkGray:
            return UIColor(white: 61/255.0, alpha: 1.0)
        case .gray:
            return UIColor(white: 121/255.0, alpha: 1.0)
        case .lightGray:
            return UIColor(white: 163/255.0, alpha: 1.0)
        case .baseGray:
            return UIColor(white: 238/255.0, alpha: 1.0)
        case .lightPurple:
            return UIColor.colorUInt8(r: 115, g: 52, b: 225)
        case .red:
            return UIColor.colorUInt8(r: 255, g: 113, b: 113)
        case .green:
            return UIColor.colorUInt8(r: 0, g: 187, b: 138)
        case .blue:
            return UIColor.colorUInt8(r: 41, g: 134, b: 255)
        case .seperator:
            return UIColor(white: 203/255.0, alpha: 1.0)
        case .clear:
            return UIColor.clear
        }
    }
    
    var cgColor: CGColor {
        return uiColor.cgColor
    }
}

extension UIColor {
    static func colorUInt8(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) -> UIColor {
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(a)/255.0)
    }
}

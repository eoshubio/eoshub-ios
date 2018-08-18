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
    case white
    case clear
    case progressGreen, progressMagenta, progressOrange
    
    var uiColor: UIColor {
        return getUIColor()
    }
    
    func getUIColor(alpha: CGFloat = 1.0) -> UIColor {
        switch self {
        case .basePurple:
            return UIColor.colorUInt8(r: 83, g: 32, b: 173, a: alpha)
        case .darkGray:
            return UIColor(white: 61/255.0, alpha: alpha)
        case .gray:
            return UIColor(white: 121/255.0, alpha: alpha)
        case .lightGray:
            return UIColor(white: 163/255.0, alpha: alpha)
        case .baseGray:
            return UIColor(white: 238/255.0, alpha: alpha)
        case .lightPurple:
            return UIColor.colorUInt8(r: 115, g: 52, b: 225, a: alpha)
        case .red:
            return UIColor.colorUInt8(r: 255, g: 113, b: 113, a: alpha)
        case .green:
            return UIColor.colorUInt8(r: 0, g: 187, b: 138, a: alpha)
        case .blue:
            return UIColor.colorUInt8(r: 41, g: 134, b: 255, a: alpha)
        case .seperator:
            return UIColor(white: 203/255.0, alpha: alpha)
        case .white:
            return UIColor(white: 1.0, alpha: alpha)
        case .clear:
            return UIColor.clear
        case .progressGreen:
            return UIColor.colorUInt8(r: 93, g: 195, b: 189, a: alpha)
        case .progressMagenta:
            return UIColor.colorUInt8(r: 226, g: 89, b: 160, a: alpha)
        case .progressOrange:
            return UIColor.colorUInt8(r: 240, g: 151, b: 92, a: alpha)
        }
    }
    
    var cgColor: CGColor {
        return uiColor.cgColor
    }
}

extension UIColor {
    static func colorUInt8(r: UInt8, g: UInt8, b: UInt8, a: CGFloat = 1.0) -> UIColor {
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: a)
    }
}

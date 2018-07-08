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
    case basePurple
    case baseGray
    
    var uiColor: UIColor {
        switch self {
        case .basePurple:
            return UIColor.colorUInt8(r: 93, g: 40, b: 187)
        case .baseGray:
            return UIColor(white: 238/255.0, alpha: 1.0)
        }
    }
}

extension UIColor {
    static func colorUInt8(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) -> UIColor {
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(a)/255.0)
    }
}

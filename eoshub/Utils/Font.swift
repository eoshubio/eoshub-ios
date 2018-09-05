//
//  Font.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

enum FontStyle: String {
    case thin, ultraLight, light, regular, medium, semiBold, bold
}

enum Font {
    case appleSDGothicNeo(FontStyle)
    
    func uiFont(_ size: CGFloat = 15) -> UIFont {
        var fontName = "AppleSDGothicNeo-Regular"
        switch self {
        case .appleSDGothicNeo(let style):
            fontName = "AppleSDGothicNeo-\(style.rawValue)"
        }
        
        let descriptor = UIFontDescriptor(name: fontName, size: size)
        
        return UIFont(descriptor: descriptor, size: size)
    }
}

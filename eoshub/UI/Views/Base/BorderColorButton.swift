//
//  BorderColorButton.swift
//  eoshub
//
//  Created by kein on 2018. 8. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class BorderColorButton: UIButton {
    private var bgColor = [UIControl.State: UIColor]()
    private var borderColor = [UIControl.State: UIColor]()
    
    
    
    override var isSelected: Bool {
        didSet {
            redraw()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            redraw()
        }
    }
    
    
    private func setBorderColor(color: UIColor, state: UIControl.State) {
        borderColor[state] = color
    }
    
    private func setBackgroundColor(color: UIColor, state: UIControl.State) {
        bgColor[state] = color
    }
    
    func setThemeColor(fgColor: UIColor, bgColor: UIColor, state: UIControl.State, border: Bool = true) {
        
        setTitleColor(fgColor, for: state)
        setBackgroundColor(color: bgColor, state: state)
        if border {
            setBorderColor(color: fgColor, state: state)
            layer.borderWidth = 1.0
        }
        
        redraw()
    }
    
    func redraw() {
        if isEnabled {
            if isSelected {
                backgroundColor = bgColor[.selected] ?? bgColor[.normal] ?? backgroundColor
                layer.borderColor = borderColor[.selected]?.cgColor ?? borderColor[.normal]?.cgColor ?? layer.borderColor
            } else {
                backgroundColor = bgColor[.normal] ?? backgroundColor
                layer.borderColor = borderColor[.normal]?.cgColor ?? layer.borderColor
            }
        } else {
            backgroundColor = bgColor[.disabled] ?? bgColor[.normal] ?? backgroundColor
            layer.borderColor = borderColor[.disabled]?.cgColor ?? borderColor[.normal]?.cgColor ?? layer.borderColor
            
        }
    }
    
}



extension UIControl.State: Hashable {
    public var hashValue: Int {
        return Int(rawValue)
    }
}




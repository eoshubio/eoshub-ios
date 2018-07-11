//
//  PurpleButton.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class PurpleButton: RoundedButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        
        layer.borderColor = Color.lightPurple.cgColor
        layer.borderWidth = 1
        
        
        let fontHeight = titleLabel?.font.pointSize ?? 12
        titleLabel?.font = Font.appleSDGothicNeo(.regular).uiFont(fontHeight)
        setTitleColor(Color.lightPurple.uiColor, for: .normal)
        
    }
    
}

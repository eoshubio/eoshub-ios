//
//  ActionButton.swift
//  eoshub
//
//  Created by kein on 2018. 7. 22..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class ActionButton: RoundedButton {
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                backgroundColor = Color.lightPurple.uiColor
            } else {
                backgroundColor = Color.baseGray.uiColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        setTitleColor(.white, for: .normal)
        
    }
}

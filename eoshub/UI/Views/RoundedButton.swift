//
//  RoundedButton.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class RoundedButton: UIButton {
    
    var radius: CGFloat = 6.0 {
        didSet {
            relayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupUI() {
        relayout()
    }
    
    private func relayout() {
        setCornerRadius(radius: radius)
    }
}

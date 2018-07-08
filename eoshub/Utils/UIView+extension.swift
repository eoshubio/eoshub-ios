//
//  RoundCornerView.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
    
    func setCornerRadius(radius: CGFloat = 6.0) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
}

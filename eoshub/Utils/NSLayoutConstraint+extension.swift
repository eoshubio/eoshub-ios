//
//  NSLayoutConstraint+extension.swift
//  eoshub
//
//  Created by kein on 2018. 8. 14..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    @discardableResult
    func changeMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        newConstraint.priority = priority
        
        NSLayoutConstraint.deactivate([self])
        NSLayoutConstraint.activate([newConstraint])
        
        return newConstraint
    }
    
}

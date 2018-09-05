//
//  RoundedButton.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class RoundedButton: BorderColorButton {
    
    
    @IBInspectable var radius: CGFloat = 6.0 {
        didSet {
            relayout()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                highlightedView?.alpha = 1.0
            } else {
                highlightedView?.alpha = 0
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                alpha = 1.0
            } else {
                alpha = 0.7
            }
        }
    }
    
    private var highlightedView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        relayout()
        
        highlightedView = UIView(frame: bounds)
        highlightedView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        highlightedView?.backgroundColor = UIColor(white: 0, alpha: 0.2)
        highlightedView?.isUserInteractionEnabled = false
        addSubview(highlightedView!)
        
        highlightedView?.alpha = 0
    }
    
    private func relayout() {
        setCornerRadius(radius: radius)
    }
    
    
   
    
    
}





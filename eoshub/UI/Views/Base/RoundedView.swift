//
//  RoundedView.swift
//  eoshub
//
//  Created by kein on 2018. 7. 9..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class RoundedView: UIView {
    
    @IBInspectable var radius: CGFloat = 3.0 {
        didSet {
            relayout()
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
        highlightedView?.backgroundColor = UIColor(white: 0, alpha: 0.5)
        highlightedView?.isUserInteractionEnabled = false
        addSubview(highlightedView!)
        
        highlightedView?.alpha = 0
    }
    
    private func relayout() {
        setCornerRadius(radius: radius)
    }
}

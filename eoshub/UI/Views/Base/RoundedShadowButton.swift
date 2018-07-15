//
//  RoundedShadowButton.swift
//  eoshub
//
//  Created by kein on 2018. 7. 15..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class RoundedShadowButton: BounceButton {
    
    @IBInspectable var radius: CGFloat = 6.0 {
        didSet {
            layoutIfNeeded()
        }
    }

    private var bgColor: UIColor? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private var backgroundLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if backgroundLayer == nil {
            backgroundLayer = CAShapeLayer()
            backgroundLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
            backgroundLayer.fillColor = bgColor?.cgColor
            backgroundLayer.shadowColor = UIColor.darkGray.cgColor
            backgroundLayer.shadowPath = backgroundLayer.path
            backgroundLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            backgroundLayer.shadowOpacity = 0.8
            backgroundLayer.shadowRadius = 2
            layer.insertSublayer(backgroundLayer, at: 0)
        }
    }
    
    
    private func setupUI() {
        layer.masksToBounds = false
        bgColor = backgroundColor
        backgroundColor = .clear

    }

}

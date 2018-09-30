//
//  WaitingView.swift
//  eoshub
//
//  Created by kein on 2018. 7. 17..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class WaitingView: UIView {
    static let shared = WaitingView()
    
    var bgView: UIView!
    
    var indicator: UIActivityIndicatorView!
    
    convenience init() {
        let frame = UIApplication.shared.keyWindow!.bounds
        self.init(frame: frame)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        bgView = UIView(frame: bounds)
        bgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(bgView)
        bgView.backgroundColor = .black
        bgView.alpha = 0.8
        
        indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.center = center
        addSubview(indicator)
    }
    
    func start() {
        if self.superview == nil {
            UIApplication.shared.keyWindow!.addSubview(self)
        }
        
        self.alpha = 0
        indicator.startAnimating()
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }
    
    func stop() {
        indicator.stopAnimating()
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    
    
    
    
    
}

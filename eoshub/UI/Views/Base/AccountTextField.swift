//
//  AccountTextField.swift
//  eoshub
//
//  Created by kein on 2018. 7. 22..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class AccountTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        addTarget(self, action: #selector(self.textFieldEditingDidChanged(_:)), for: .editingChanged)
        
    }
    
    @objc fileprivate func textFieldEditingDidChanged(_ sender: Any) {
        guard let accountName = text, accountName.count > 0 else { return }
        
        let wrongChrs = Validator.wrongAccountName(name: accountName)
        
        let attrText = NSMutableAttributedString(string: accountName)
        wrongChrs.forEach { attrText.addAttribute(.foregroundColor, value: Color.red.uiColor, range: $0) }
        
        attributedText = attrText
        
    }

    
}

//
//  FormattedNumberField.swift
//  eoshub
//
//  Created by kein on 2018. 7. 20..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class FormattedNumberField: UITextField {
    
    enum DotStyle {
        case dot4
        case none
        
        var precision: Int {
            switch self {
            case .dot4:
                return 4
            default:
                return 0
            }
        }
    }
    
    var style: DotStyle = .dot4
    
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
        guard let input = text?.replacingOccurrences(of: ",", with: "") else { return }
        
        let components = input.components(separatedBy: ".")
        
        var result = (components.first ?? "0").decimalFormatted
        
        if components.count == 2, let dotPart = components.last, style != .none  {
            result = result + "." + dotPart.substring(precision: style.precision)
        }
        
        text = result
    }
    
}



//
//  FaceIdInputView.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class FaceIdInputView: UIButton {
    
    @IBOutlet fileprivate weak var lbDescription: UILabel!
    @IBOutlet fileprivate weak var btnIcon: UIButton!
    
    override var isSelected: Bool {
        didSet {
            btnIcon.isSelected = isSelected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func setDescription(text: String) {
        lbDescription.text = text
    }
}

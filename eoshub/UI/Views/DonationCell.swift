//
//  DonationCell.swift
//  eoshub
//
//  Created by kein on 2018. 8. 26..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class DonationCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        let donationAccount = "EOSHub"
        let text = NSMutableAttributedString(string: "Donate to EOSHub")
        text.addAttributeFont(text: donationAccount, font: Font.appleSDGothicNeo(.semiBold).uiFont(14))
        text.addAttributeColor(text: donationAccount, color: Color.basePurple.uiColor)
        lbTitle.attributedText = text
    }
    
}

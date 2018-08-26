//
//  WalletAddCell.swift
//  eoshub
//
//  Created by kein on 2018. 7. 9..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class WalletAddCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var lbDonation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        let text = NSMutableAttributedString(string: "Donation: eoshuborigin")
        text.addAttributeFont(text: "eoshuborigin", font: Font.appleSDGothicNeo(.semiBold).uiFont(14))
        lbDonation.attributedText = text
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}


enum WalletAddCellType: CellType {
    case add, guide
    
    var nibName: String {
        switch self {
        case .add:
            return "WalletAddCell"
        case .guide:
            return "WalletGuideCell"
        }
        
    }
}

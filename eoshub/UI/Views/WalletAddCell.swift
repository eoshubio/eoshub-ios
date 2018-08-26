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
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func setupUI() {
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}


enum WalletAddCellType: CellType {
    case add, guide, donation
    
    var nibName: String {
        switch self {
        case .add:
            return "WalletAddCell"
        case .guide:
            return "WalletGuideCell"
        case .donation:
            return "DonationCell"
        }
        
    }
}

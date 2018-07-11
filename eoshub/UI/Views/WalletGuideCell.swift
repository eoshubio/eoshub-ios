//
//  WalletGuideCell.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class WalletGuideCell: UITableViewCell {
    @IBOutlet fileprivate weak var greeting: UILabel!
    @IBOutlet fileprivate weak var guide: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        greeting.text = LocalizedString.Wallet.First.greeting
        guide.text = LocalizedString.Wallet.First.guide
    }
}



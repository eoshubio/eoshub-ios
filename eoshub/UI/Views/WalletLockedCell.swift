//
//  WalletLockedCell.swift
//  eoshub
//
//  Created by kein on 2018. 8. 7..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class WalletLockedCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var lbInactive: UILabel!
    @IBOutlet fileprivate weak var lbActivationGuide: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func setupUI() {
        lbInactive.text = LocalizedString.Wallet.Inactive.account
        lbActivationGuide.text = LocalizedString.Wallet.Inactive.guide
    }
    
}


class InactiveWallet: CellType {
    
    var nibName: String { return "WalletLockedCell" }
    
    let ehaccount: EHAccount
    
    init(account: EHAccount) {
        self.ehaccount = account
    }
    
}

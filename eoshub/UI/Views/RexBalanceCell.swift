//
//  RexBalanceCell.swift
//  eoshub
//
//  Created by kein on 06/05/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation

class RexBalanceCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbRex: UILabel!
    @IBOutlet fileprivate weak var lbEOS: UILabel!
    
    func configure(balance: RexBalance) {
        lbRex.text = balance.rexBalance.balance
        lbEOS.text = "≈ " + balance.voteStake.balance //TODO: change to estimated value
    }
}

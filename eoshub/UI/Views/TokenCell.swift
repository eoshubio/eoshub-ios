//
//  TokenCell.swift
//  eoshub
//
//  Created by kein on 2018. 7. 15..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class TokenCell: UITableViewCell {
    @IBOutlet fileprivate var balance: UILabel!
    @IBOutlet fileprivate var symbol: UILabel!
    @IBOutlet fileprivate var icon: UIImageView!
    
    
    func configure(currency: Currency) {
        balance.text = currency.balance
        symbol.text = currency.symbol
    }
}


struct TokenBalanceInfo: CellType {
    var nibName: String {
        return "TokenCell"
    }
    
    let owner: AccountInfo
    
    let symbol: Symbol
    
    var currency: Currency {
        return owner.tokens.filter { $0.symbol == symbol }.first ?? Currency(balance: 0, symbol: symbol)
    }
    
    var balance: String {
        return currency.balance
    }
    
    var quantity: Double {
        //TODO: symbol -> symbol + contract
        return currency.quantity
        
    }
    
}

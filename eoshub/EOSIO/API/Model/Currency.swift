//
//  Currency.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 18..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

struct Currency {
    let quantity: Double
    let balance: String
    let symbol: String
    let currency: String
    var prettyFormated: String {
        return balance + " " + symbol
    }
    
    init?(currency: String) {
        let comp = currency.components(separatedBy: " ")
        if comp.count != 2 {
            return nil
        } else {
            self.quantity = Double(comp.first!)!
            self.balance = String(format: "%.4f", quantity)
            self.symbol = comp.last!
            self.currency = currency
        }
    }

}

extension Currency {
    static let zeroEOS = Currency(currency: "0.0000 EOS")!
}

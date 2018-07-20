//
//  Currency.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 18..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

typealias Symbol = String

struct Currency {
    let quantity: Double
    let balance: String
    let symbol: Symbol
    let currency: String
    
    init?(currency: String) {
        let comp = currency.components(separatedBy: " ")
        if comp.count != 2 {
            return nil
        } else {
            
            let balanceRaw = comp.first!
            
            self.quantity = Double(balanceRaw)!
            self.balance = balanceRaw.dot4String
            self.symbol = comp.last!
            self.currency = balance + " " + symbol
        }
    }
    
    init(balance: Double, symbol: String) {
        self.quantity = balance
        self.balance = balance.dot4String
        self.symbol = symbol
        self.currency = self.balance + " " + symbol
    }

}

extension Currency {
    static let zeroEOS = Currency(currency: "0.0000 EOS")!
}

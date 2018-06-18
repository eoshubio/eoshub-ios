//
//  Currency.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 18..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

struct Currency {
    let balance: String
    let symbol: String
    let currency: String
    
    init?(currency: String) {
        let comp = currency.components(separatedBy: " ")
        if comp.count != 2 {
            return nil
        } else {
            self.currency = currency
            self.balance = comp.first!
            self.symbol = comp.last!
        }
    }

}

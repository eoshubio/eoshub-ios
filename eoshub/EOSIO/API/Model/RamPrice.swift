//
//  Ramprice.swift
//  eoshub
//
//  Created by kein on 2018. 7. 18..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

struct RamPrice: JSONInitializable {
    let supply: Currency
    let baseBalance: Double
    let baseWeight: Double
    
    let quoteBalance: Currency
    let quoteWeight: Double
    
    
    var ramPriceKB: Double {
        if quoteBalance.quantity <= 0 {
            return 0
        }
        return baseBalance / quoteBalance.quantity
    }
    
    init?(json: JSON) {
        guard let supply = json.string(for: "supply"),
            let base = json.json(for: "base"),
            let baseBalance = base.string(for: "balance"),
            let parsedBalance = baseBalance.components(separatedBy: " ").first,
            let baseWeight = base.string(for: "weight"),
            let quote = json.json(for: "quote"),
            let quoteBalance = quote.string(for: "balance"),
            let quoteWeight = quote.string(for: "weight") else { return nil }
        
        self.supply = Currency(eosCurrency: supply) ?? .zeroEOS
        self.baseBalance = Double(Int64(parsedBalance)!)
        self.baseWeight = Double(baseWeight)!
        self.quoteBalance = Currency(eosCurrency: quoteBalance) ?? .zeroEOS
        self.quoteWeight = Double(quoteWeight)!
        
    }
    
}

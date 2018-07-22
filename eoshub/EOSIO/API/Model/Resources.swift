//
//  Resources.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 26..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

struct Resources: JSONInitializable {
    let netWeight: Currency
    let cpuWeight: Currency
    let ramBytes: Int64
    
    var staked: Double {
        return netWeight.quantity + cpuWeight.quantity
    }
    
    init?(json: JSON) {
        guard let net = json["net_weight"] as? String else { return nil }
        guard let cpu = json["cpu_weight"] as? String else { return nil }
        guard let ram = json["ram_bytes"] as? Int64 else { return nil }
        
        self.netWeight = Currency(eosCurrency: net) ?? .zeroEOS
        self.cpuWeight = Currency(eosCurrency: cpu) ?? .zeroEOS
        self.ramBytes = ram
    }
    
    init() {
        netWeight = Currency.zeroEOS
        cpuWeight = Currency.zeroEOS
        ramBytes = 0
    }
    
}

extension Resources {
    static let zero = Resources()
}

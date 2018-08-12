//
//  Invoice.swift
//  eoshub
//
//  Created by kein on 2018. 8. 12..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation



struct Invoice: JSONInitializable {
    let totalEOS: Currency
    let memo: String
    let timestamp: Double
    
    //TODO: get from server
    var creator = "eoshubiogate"
    var cpu: Currency = Currency(balance: 0.2, token: .eos)
    var net: Currency = Currency(balance: 0.01, token: .eos)
    var ram: Int64 = 5120
    
    init?(json: JSON) {
        guard let json = json.json(for: "resultData") else { return nil }
        guard let memo = json.json(for: "memo") else { return nil }
        
        guard let eos = memo.double(for: "eos"),
                let code = memo.string(for: "code"),
                let timestamp = memo.double(for: "createdAt") else { return nil }
        
        self.totalEOS = Currency(balance: eos, token: .eos)
        self.memo = code
        self.timestamp = timestamp / 1000.0
    }
    
    init(totalEOS: Currency, memo: String, timestamp: Double, creator: String, cpu: Currency, net: Currency, ram: Int64) {
        self.totalEOS = totalEOS
        self.memo = memo
        self.timestamp = timestamp
        self.creator = creator
        self.cpu = cpu
        self.net = net
        self.ram = ram
    }
    
}

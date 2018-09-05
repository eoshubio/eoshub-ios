//
//  Invoice.swift
//  eoshub
//
//  Created by kein on 2018. 8. 12..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation



struct Invoice: JSONInitializable {
    
    let completed: Bool
    
    let memo: String
    let totalEOS: Currency
    let createdAt: Double
    let expiredAt: Double
    let expireTime: Int
    
    let creator: String
    let cpu: Currency
    let net: Currency
    let ram: Int64
    
    var expireHour: Int {
        return Int(Double(expireTime) / 3600.0)
    }
    
    init?(json: JSON) {
        guard let json = json.json(for: "resultData") else { return nil }
        guard let memo = json.json(for: "memo") else { return nil }
        
        guard let code = memo.string(for: "code"),
                let completed = memo.bool(for: "complete"),
                let createdAt = memo.double(for: "createdAt"),
                let expiredAt = memo.double(for: "expiredAt") else { return nil }
        
        guard let eosString = json.string(for: "eos"),
              let creator = json.string(for: "creator"),
              let expireTime = json.integer(for: "expireTime"),
              let eos = Currency(eosCurrency: eosString),
              let cpuString = json.string(for: "cpu"),
              let cpu = Currency(eosCurrency: cpuString),
              let netString = json.string(for: "net"),
              let net = Currency(eosCurrency: netString),
              let ram = json.integer64(for: "ram") else {
                return nil
        }
        self.completed = completed
        
        self.memo = code
        self.creator = creator
        self.totalEOS = eos
        self.cpu = cpu
        self.net = net
        self.ram = ram
        self.createdAt = createdAt / 1000.0
        self.expiredAt = expiredAt / 1000.0
        self.expireTime = expireTime
    }
    
    init(completed: Bool, totalEOS: Currency, memo: String,
         createdAt: Double, expiredAt: Double, expireTime: Int,
         creator: String,
         cpu: Currency, net: Currency, ram: Int64) {
        self.completed = completed
        self.totalEOS = totalEOS
        self.memo = memo
        self.createdAt = createdAt
        self.expiredAt = expiredAt
        self.creator = creator
        self.cpu = cpu
        self.net = net
        self.ram = ram
        self.expireTime = expireTime
    }
    
}

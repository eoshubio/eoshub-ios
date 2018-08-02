//
//  Currency.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 18..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

typealias Symbol = String

struct Token: Equatable, Hashable {
    let symbol: Symbol
    let contract: String
    let decimal = 4
    
    var stringValue: String {
        return symbol + "@" + contract
    }
    
    init(symbol: Symbol, contract: String) {
        self.symbol = symbol
        self.contract = contract
    }
    
    init?(with stringValue: String) {
        let comp = stringValue.components(separatedBy: "@")
        if comp.count != 2 {
            return nil
        } else {
            self.symbol = comp.first!
            self.contract = comp.last!
        }
    }
}

extension Token {
    static let eos = Config.eosInfo.token
    static let pandora = Config.pandoraInfo.token
}

struct Currency {
    let quantity: Double
    let balance: String
    let token: Token
    
    var symbol: Symbol {
        return token.symbol
    }
    
    var stringValue: String {
        return balance + " " + token.symbol
    }
    
    //balance + symbol + @contract
    var rawValue: String { //for save to db
        return balance + " " + token.stringValue
    }
    
    
    init(balance: Double, token: Token = .eos) {
        self.quantity = balance
        self.balance = balance.dot4String
        self.token = token
        
    }
    
    init(balance: String, token: Token = .eos) {
        self.quantity = Double(balance) ?? 0
        self.balance = balance.fillZero(zeroCount: token.decimal)
        self.token = token
    }
    
    init?(eosCurrency: String) {
        let comp = eosCurrency.components(separatedBy: " ")
        if comp.count == 2 {
            let balance = comp.first!
            self.quantity = Double(balance) ?? 0
            self.balance = balance.fillZero()
            self.token = .eos
        } else {
            return nil
        }
    }
    
    //cf) rawValue: "1.0000 EOS@eosio.token"
    static func create(rawValue: String) -> Currency? {
        let comp = rawValue.components(separatedBy: " ")
        if comp.count == 2, let token = Token(with: comp.last!) {
            let currency = Currency(balance: comp.first!, token: token)
            return currency
        }
        return nil
    }
    
    //cf) stringValue: "1.0000 EOS", contract: "eosio.token"
    static func create(stringValue: String, contract: String) -> Currency? {
        let comp = stringValue.components(separatedBy: " ")
        if comp.count == 2 {
            let token = Token(symbol: comp.last!, contract: contract)
            let currency = Currency(balance: comp.first!, token: token)
            return currency
        }
        return nil
    }
    
}

extension Currency {
    static let zeroEOS = Currency(balance: 0, token: .eos)
}




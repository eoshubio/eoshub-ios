//
//  TokenInfo.swift
//  eoshub
//
//  Created by kein on 2018. 7. 14..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import RealmSwift

class TokenInfo: DBObject, Mergeable {
    @objc dynamic var contract: String = ""
    @objc dynamic var symbol: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var decimal: Int = 4
    
    var token: Token {
        return Token(symbol: symbol, contract: contract)
    }
    
    override static func ignoredProperties() -> [String] {
        return ["token"]
    }
    
    convenience init(contract: String, symbol: String, name: String?, decimal: Int = 4) {
        self.init()
        self.id = symbol + "@" + contract
        self.contract = contract
        self.symbol = symbol
        self.name = name ?? symbol
        self.decimal = decimal
    }
    
    static func create(json: JSON) -> TokenInfo? {
        guard let code = json.string(for: "code")?.lowercased(),
            let symbol = json.string(for: "symbol")?.uppercased(),
            let decimal = json.integer(for: "decimal") else {
                return nil
        }
        
        let name = json.string(for: "name")
        
        return TokenInfo(contract: code, symbol: symbol, name: name, decimal: decimal)
    }
    
    func mergeChanges(from newObject: TokenInfo) {
        contract = newObject.contract
        symbol = newObject.symbol
        name = newObject.name
        decimal = newObject.decimal
    }
    
}

extension TokenInfo {
    static let eos = Config.eosInfo
    static let pandora = Config.pandoraInfo  
}

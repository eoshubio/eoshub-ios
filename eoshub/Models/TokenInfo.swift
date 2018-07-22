//
//  TokenInfo.swift
//  eoshub
//
//  Created by kein on 2018. 7. 14..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import RealmSwift

class TokenInfo: DBObject {
    @objc dynamic var contract: String = ""
    @objc dynamic var symbol: String = ""
    @objc dynamic var name: String = ""
    
    
    var token: Token {
        return Token(symbol: symbol, contract: contract)
    }
    
    override static func ignoredProperties() -> [String] {
        return ["token"]
    }
    
    convenience init(contract: String, symbol: String, name: String?) {
        self.init()
        self.id = symbol
        self.contract = contract
        self.symbol = symbol
        self.name = name ?? symbol
    }
    
}

extension TokenInfo {
    static let pandora = Config.pandoraInfo  
}

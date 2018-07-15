//
//  Tx.swift
//  eoshub
//
//  Created by kein on 2018. 7. 15..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

struct Tx: JSONInitializable, Hashable {
    
    var hashValue: Int {
        return hashId.hashValue
    }
    
    static func == (lhs: Tx, rhs: Tx) -> Bool {
        return lhs.hashId == rhs.hashId
    }
    
    let id: String
    let hashId: String
    let from: String
    let to: String
    let quantity: Currency
    let symbol: Symbol
    let memo: String
    let timeStamp: TimeInterval
    
    init?(json: JSON) {
        guard let action = json.json(for: "action_trace") else { return nil }
        guard let txid = action.string(for: "trx_id") else { return nil }
        self.id = txid
        self.hashId = String(txid[0...5])
        guard let blockTime = json.string(for: "block_time")
            , let timestamp = Date.UTCToDate(date: blockTime)?.timeIntervalSince1970 else  { return nil }
        
        self.timeStamp = timestamp
        
        guard let data = action.json(for: "act")?.json(for: "data") else { return nil }
        guard let from = data.string(for: "from"),
                let to = data.string(for: "to"),
            let quantity = data.string(for: "quantity"),
                let memo = data.string(for: "memo") else { return nil}
        
        
        self.from = from
        self.to = to
        self.quantity = Currency(currency: quantity)!
        self.symbol = self.quantity.symbol
        self.memo = memo
        
    }
}

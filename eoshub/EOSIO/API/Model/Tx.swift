//
//  Tx.swift
//  eoshub
//
//  Created by kein on 2018. 7. 15..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

class Tx: DBObject, JSONInitializable, Mergeable {
    
    override var hashValue: Int {
        return hashId.hashValue
    }
    
    static func == (lhs: Tx, rhs: Tx) -> Bool {
        return lhs.hashId == rhs.hashId
    }
    @objc dynamic var txid: String = ""
    @objc dynamic var hashId: String = ""
    @objc dynamic var action: String = ""
    @objc dynamic var contract: String = ""

    @objc dynamic var timeStamp: TimeInterval = 0
    @objc dynamic var data: String = ""
    
    convenience required init?(json: JSON) {
        self.init()
        guard let action = json.json(for: "action_trace") else { return nil }
        guard let txid = action.string(for: "trx_id") else { return nil }
        self.txid = txid
        self.hashId = String(txid[0...5])
        guard let blockTime = json.string(for: "block_time")
            , let timestamp = Date.UTCToDate(date: blockTime)?.timeIntervalSince1970 else  { return nil }
        
        self.timeStamp = timestamp
        
        guard let act = action.json(for: "act") else { return nil }
        guard let actionName = act.string(for: "name") else { return nil }
        guard let contract = act.string(for: "account") else { return nil }
        
        self.id = actionName + txid
        
        guard let data = act.json(for: "data") else { return nil }
        
        self.action = actionName
        
        self.contract = contract
        
        self.data = data.stringValue ?? ""
        
        
//        guard let from = data.string(for: "from"),
//                let to = data.string(for: "to"),
//            let currencyString = data.string(for: "quantity"),
//                let currency = Currency(currency: currencyString),
//                let memo = data.string(for: "memo") else { return nil}
//
//
//
//        self.from = from
//        self.to = to
//        self.quantity = currency.quantity
//        self.symbol = currency.symbol
//        self.memo = memo
    }
    
    func mergeChanges(from newObject: Tx) {
        timeStamp = newObject.timeStamp
        data = newObject.data
//        from = newObject.from
//        to = newObject.to
//        quantity = newObject.quantity
//        symbol = newObject.symbol
//        memo = newObject.memo
    }
}

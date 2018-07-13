//
//  Transaction.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

class Transaction: TransactionHeader {
    var actions: [Action] = []
    let contextFreeAction: [Action] = [] //not used
    let transactionExtension: [UInt8] = [] // not used
    
     override var json: JSON {
        var params: JSON = super.json
        params["context_free_actions"] = contextFreeAction
        params["actions"] = actions.map { $0.json }
        params["transaction_extensions"] = transactionExtension
        
        return params
    }
    
    @discardableResult override func serialize(pack: Pack) -> Pack {
        super.serialize(pack: pack)
        pack.putVariableUInt(value: contextFreeAction.count)
        
        pack.putVariableUInt(value: actions.count)
        actions.forEach { $0.serialize(pack: pack) }
        
        pack.putVariableUInt(value: transactionExtension.count)
        
        return pack
    }
    
    init(block: Block, actions: [Action]) {
        super.init(block: block)
        self.actions = actions
    }
    
    required init?(json: JSON) {
        super.init(json: json)
        self.actions = json.arrayJson(for: "actions")?.compactMap(Action.init) ?? []
    }
    
}

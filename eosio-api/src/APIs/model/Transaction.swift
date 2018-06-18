//
//  Transaction.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

struct Transaction: JSONOutput {
//    private let timeinterval: TimeInterval = 180
    private let timeinterval: TimeInterval = 180 * 10
    let expiration: String
    let refBlockNum: Int64
    let refBlockPrefix: Int64
    let actions: [Action]
    
    var json: JSON {
        var params: JSON = [:]
        params["expiration"] = expiration
        params["ref_block_num"] = refBlockNum
        params["ref_block_prefix"] = refBlockPrefix
        params["actions"] = actions.map { $0.json }
        params["signatures"] = []
        return params
    }
    
    init(block: Block, actions: [Action]) {
        expiration = block.timeStamp.addingTimeInterval(timeinterval).dateToUTC()
        refBlockNum = block.blockNum
        refBlockPrefix = block.refBlockPrefix
        self.actions = actions
    }
    
}

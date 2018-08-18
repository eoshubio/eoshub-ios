//
//  Block.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

struct Block: JSONInitializable {
    let blockNum: Int
    let timeStamp: Date
    let refBlockPrefix: Int64
    
    init?(json: JSON) {
        guard let blockNum = json.integer(for: "block_num") else { return nil }
        guard let timeStamp = json["timestamp"] as? String else { return nil }
        guard let date = Date.UTCToDate(date: timeStamp) else { return nil }
        guard let refBlockPrefix = json.integer64(for: "ref_block_prefix") else { return nil }
        
        self.blockNum = blockNum
        self.timeStamp = date
        self.refBlockPrefix = refBlockPrefix
    }
}

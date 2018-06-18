//
//  SignedTransaction.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

struct SignedTransaction: JSONInitializable, JSONOutput {
    
    var trx: JSON
    
    var json: JSON {
        var params: JSON = [:]
        params["compression"] = "none"
        params["transaction"] = trx
        params["signatures"] = trx["signatures"] ?? []
        return params
    }
    
    init?(json: JSON) {
        self.trx = json
        trx["transaction_extensions"] = []
        trx["context_free_actions"] = []
    }
    
}

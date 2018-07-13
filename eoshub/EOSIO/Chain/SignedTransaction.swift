//
//  SignedTransaction.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

class SignedTransaction: Transaction {
    
    var signatures: [String] = []
    var contextFreeData: [String] = []
    

    
    override var json: JSON {
        var params: JSON = [:]
        params["compression"] = "none"
        params["transaction"] = super.json
        params["signatures"] = signatures

        return params
    }
    
    required init?(json: JSON) {
        super.init(json: json)
        signatures = json.arrayString(for: "signatures") ?? []
    }
}

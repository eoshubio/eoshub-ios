//
//  Authority.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

struct Authority: JSONOutput {
    let key: String
    
    var json: JSON {
        var params: JSON = [:]
        params["threshold"] = 1
        params["accounts"] = []
        params["keys"] = [["key": key, "weight": 1]]
        params["waits"] = []
        return params
    }
    
}

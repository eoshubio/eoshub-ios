//
//  Action.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

struct Action: JSONOutput {
    let account: String //Contract.code
    let name: String //Contract.action
    let authorization: Authorization
    let data: String //binary
    
    var json: JSON {
        var params: JSON = [:]
        params["account"] = account
        params["name"] = name
        params["authorization"] = [authorization.json]
        params["data"] = data
        return params
    }
}

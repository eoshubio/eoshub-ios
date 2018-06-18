//
//  Contract.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

struct Contract: JSONOutput {
    let code: String
    let action: String
    let args: JSON
    let authorization: Authorization
    
    var json: JSON {
        var param: JSON = [:]
        param["code"] = code
        param["action"] = action
        param["args"] = args
        return param
    }
}

extension Contract {
    static func newAccount(name: String, owner: Authority, active: Authority, authorization: Authorization) -> Contract {
        let agrs: JSON = ["creator": authorization.actor, "name": name, "owner": owner.json, "active": active.json ]
        let contract = Contract(code: "eosio", action: "newaccount", args: agrs, authorization: authorization)
        return contract
    }
    
    static func transfer(from: String, to: String, quantity: Currency, memo: String = "") -> Contract {
        let contract = Contract(code: "eosio.token",
                                action: "transfer",
                                args: ["from": from, "to": to, "quantity": quantity.currency, "memo": memo],
                                authorization: Authorization(actor: from, permission: .active))
        return contract
    }
}

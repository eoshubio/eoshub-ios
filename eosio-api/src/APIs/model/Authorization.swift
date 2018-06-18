//
//  Authorization.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

struct Authorization: JSONOutput {
    static let eosio = Authorization(actor: "eosio", permission: .active)
    
    let actor: String
    let permission: Permission
    
    var json: JSON {
        return ["actor": actor, "permission": permission.rawValue]
    }
    
}

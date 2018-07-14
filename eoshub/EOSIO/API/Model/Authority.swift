//
//  Authority.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

struct Authority: JSONOutput, JSONInitializable {
    let permission: Permission
    let keys: [Key]
    var threshold = 1
    
    var json: JSON {
        var params: JSON = [:]
        params["threshold"] = threshold
        params["accounts"] = []
        params["keys"] = keys.map { $0.json }
        params["waits"] = []
        return params
    }
    
    init?(json: JSON) {
        permission = Permission(json.string(for: "perm_name") ?? "active")
        let auth = json.json(for: "required_auth")
        
        keys = auth?.arrayJson(for: "keys")?.compactMap(Key.init) ?? []
        
        threshold = auth?.integer(for: "threshold") ?? threshold
    }
    
    init(key: String, perm: Permission) {
        permission = perm
        keys = [Key(key: key)]
    }
    
}


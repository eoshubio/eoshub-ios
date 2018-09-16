//
//  StoredKey.swift
//  eoshub
//
//  Created by kein on 2018. 9. 16..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

struct StoredKey: JSONOutput, JSONInitializable {
    let eosioKey: Key
    let permission: Permission
    let repo: KeyRepository
    
    var json: JSON {
        return ["eosioKey": eosioKey.json,
                "permission": permission.value,
                "repo": repo.rawValue]
    }
    
    init?(json: JSON) {
        guard let eosKey = json.json(for: "eosioKey"),
              let perm = json.string(for: "permission"),
              let repo = json.string(for: "repo") else { return nil }
        
        guard let key = Key(json: eosKey),
            let keyRepo = KeyRepository(rawValue: repo) else { return nil }
        
        self.eosioKey = key
        self.permission = Permission(perm)
        self.repo = keyRepo
    }
    
    init(eosioKey: Key, permission: Permission, repo: KeyRepository) {
        self.eosioKey = eosioKey
        self.permission = permission
        self.repo = repo
    }
    
}

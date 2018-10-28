//
//  Authorization.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

class Authorization: Packable, JSONInitializable, JSONOutput {
    
    @discardableResult func serialize(pack: Pack) -> Pack {
        actor.serialize(pack: pack)
        permission.serialize(pack: pack)
        return pack
    }
    
    let actor: EOSName
    let permission: Permission
    
    var json: JSON {
        return ["actor": actor.value, "permission": permission.value]
    }
    
    var stringValue: String {
        return actor.value + "@" + permission.value
    }
    
    init(actor: EOSName, permission: Permission) {
        self.actor = actor
        self.permission = permission
    }
    
    init(actor: String, permission: Permission) {
        self.actor = EOSName(actor)
        self.permission = permission
    }
    
    init(actor: String, permission: String) {
        self.actor = EOSName(actor)
        self.permission = Permission(permission)
    }
    
    required init?(json: JSON) {
        guard let actor = json.string(for: "actor") else { return nil }
        guard let permission = json.string(for: "permission") else { return nil }
        self.actor = EOSName(actor)
        self.permission = Permission(permission)
    }
}

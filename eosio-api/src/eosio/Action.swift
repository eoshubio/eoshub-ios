//
//  Action.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

class Action: Packable, JSONInitializable, JSONOutput  {
    
    @discardableResult func serialize(pack: Pack) -> Pack {
        account.serialize(pack: pack)
        action.serialize(pack: pack)
        pack.putVariableUInt(value: authorization.count)
        authorization.forEach { $0.serialize(pack: pack) }
        
        let bytes = binary.hexToBytes
        pack.putVariableUInt(value: bytes.count)
        if bytes.count > 0 {
            pack.put(bytes: bytes)
        }
        return pack
    }
    
    let account: EOSName //Contract.code
    let action: EOSName //Contract.action
    let authorization: [Authorization]
    let binary: String //binary
    
    var json: JSON {
        var params: JSON = [:]
        params["account"] = account.value
        params["name"] = action.value
        params["authorization"] = authorization.map{ $0.json }
        params["data"] = binary
        return params
    }
    
    init(account: EOSName, action: EOSName, authorization: [Authorization], binary: String) {
        self.account = account
        self.action = action
        self.authorization = authorization
        self.binary = binary
    }
    
    convenience init(account: String, action: String, authorization: Authorization, binary: String) {
        self.init(account: EOSName(account), action: EOSName(action), authorization: [authorization], binary: binary)
    }
    
    required init?(json: JSON) {
        guard let data = json.string(for: "data") else { return nil }
        guard let account = json.string(for: "account") else { return nil }
        guard let name = json.string(for: "name") else { return nil }
        self.binary = data
        self.account = EOSName(account)
        self.action = EOSName(name)
        self.authorization = json.arrayJson(for: "authorization")?.compactMap(Authorization.init) ?? []
    }
}

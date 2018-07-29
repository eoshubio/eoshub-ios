//
//  ABI.swift
//  eoshub
//
//  Created by kein on 2018. 7. 29..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

struct ABI: JSONInitializable {
    
    let code: String
    
    var actions: [Action] = []
    
    let structs: [Struct]
    
    struct Action {
        let name: String
        let fields: Struct?
        
    }
    
    struct Struct: JSONInitializable {
        let name: String
        let fields: [String] //TODO [String] to [Field]
        
        init?(json: JSON) {
            guard let name = json.string(for: "name") else { return nil }
            self.name = name
            self.fields = json.arrayJson(for: "fields")?.compactMap {$0.string(for: "name")} ?? []
        }
    }
    
    init?(json: JSON) {
        guard let code = json.string(for: "account_name") else { return nil }
        guard let abi = json.json(for: "abi") else { return nil }
        guard let actionNames = abi.arrayJson(for: "actions")?.compactMap({$0.string(for: "name")}) else { return nil }
        guard let structs = abi.arrayJson(for: "structs") else { return nil }
        
        self.code = code
        self.structs = structs.compactMap(Struct.init)
        
        actionNames.forEach { (name) in
            let fields = self.structs.filter({$0.name == name}).first
            let action = Action(name: name, fields: fields)
            actions.append(action)
        }
    }
}

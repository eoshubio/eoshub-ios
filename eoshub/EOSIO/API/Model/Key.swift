//
//  Key.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

struct Key: JSONInitializable, JSONOutput {
    let key: String
    var weight = 1
    
    var json: JSON {
        return ["key": key, "weight": weight]
    }
    
    init?(json: JSON) {
        key = json.string(for: "key") ?? ""
        weight = json.integer(for: "weight") ?? weight
    }
    
    init(key: String) {
        self.key = key
    }
    
}


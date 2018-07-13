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

class Key: DBObject {
    
    convenience init(value: String) {
        self.init()
        id = value
    }
    
}


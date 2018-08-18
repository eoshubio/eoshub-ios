//
//  DBObject.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import RealmSwift

class DBObject: RealmSwift.Object {
    
    override static func primaryKey() -> String? { return "id" }
    
    @objc dynamic var id = ""
    
    public static func ==(lhs: DBObject, rhs: DBObject) -> Bool {
        return lhs.id == rhs.id
    }
}




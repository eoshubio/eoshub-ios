//
//  Wallet.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import RxSwift

class Wallet: DBObject {
  
    @objc dynamic var name: String = ""
    //TODO: encyrpt wallet password
    @objc dynamic var password: String = ""
    
    @objc dynamic var publicKey: String = ""
    
    var paramter: [String] {
        return [name, password]
    }
    
    
    convenience init(name: String, password: String) {
        self.init()
        self.id = password
        self.name = name
        self.password = password
    }
    
}


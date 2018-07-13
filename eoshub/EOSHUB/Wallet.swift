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
  
    @objc dynamic var account: String = ""
    
    @objc dynamic var publicKey: String = ""
    
    convenience init(account: String, publicKey: String) {
        self.init()
        self.id = account
        self.account = account
        self.publicKey = publicKey
    }
    
}


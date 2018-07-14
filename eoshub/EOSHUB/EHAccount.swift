//
//  Account.swift
//  eoshub
//
//  Created by kein on 2018. 7. 13..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

import Foundation
import Realm
import RealmSwift
import RxSwift

class EHAccount: DBObject {
    
    @objc dynamic var account: String = ""
    
    @objc dynamic var publicKey: String = ""
    
    @objc dynamic var created: TimeInterval = 0
    
    @objc dynamic var owner: Bool = true
    
    
    convenience init(account: String, publicKey: String, owner: Bool) {
        self.init()
        self.id = account
        self.account = account
        self.publicKey = publicKey
        self.owner = owner
        created = Date().timeIntervalSince1970
    }
    
}


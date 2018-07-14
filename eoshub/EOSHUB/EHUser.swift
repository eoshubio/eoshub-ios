//
//  EHUser.swift
//  eoshub
//
//  Created by kein on 2018. 7. 13..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

import Realm
import RealmSwift
import RxSwift

class EHUser: DBObject {
    
    @objc dynamic var accounts: String = ""
    @objc dynamic var from: String = ""
    
    convenience init(id: String, loginType: LoginType) {
        self.init()
        self.id = id
        self.from = loginType.rawValue
    }
    
}



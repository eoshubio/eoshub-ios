//
//  RealmString.swift
//  eoshub
//
//  Created by kein on 2018. 7. 14..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import RealmSwift

class RealmString: Object {
    @objc dynamic var stringValue = ""
    
    convenience init(value: String) {
        self.init()
        stringValue = value
    }
}

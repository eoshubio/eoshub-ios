//
//  CreateAccountRequest.swift
//  eoshub
//
//  Created by kein on 2018. 8. 11..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import RealmSwift

class CreateAccountRequest: DBObject {
    
    @objc dynamic var userId: String = ""
    
    //account stage
    @objc dynamic var name: String = ""
    @objc dynamic var ownerKey: String = ""
    @objc dynamic var activeKey: String = ""
    @objc dynamic var _keyFrom: String = ""
    
    //invoice stage
    @objc dynamic var cpu = "0.2000 EOS"
    @objc dynamic var net = "0.0100 EOS"
    @objc dynamic var ram = "5120"
    
    @objc dynamic var creator: String = ""
    @objc dynamic var memo: String = ""
    @objc dynamic var total: String = ""
    @objc dynamic var created: Double = 0
    @objc dynamic var expireTime: Double = 3600
    
    @objc dynamic var completed: Bool = false

    var keyFrom: CreateKeyMode {
        return CreateKeyMode(rawValue: _keyFrom) ?? .none
    }
    
    enum Stage: Int {
        case prepare, accountCheck, invoice, expired, completed
    }
    
    var currentStage: Stage {
        var stage: Stage = .prepare
        
        let accountChecked = (name.count > 0 && ownerKey.count > 0 && activeKey.count > 0)
        let invoice = (creator.count > 0 && memo.count > 0 && total.count > 0)
        let expired = created + expireTime > Date().timeIntervalSince1970 
        if completed {
            stage = .completed
        } else if accountChecked {
            if expired {
                stage = .expired
            } else if invoice {
                stage = .invoice
            } else {
                stage = .accountCheck
            }
        }
        return stage
    }
    
    override static func ignoredProperties() -> [String] {
        return ["currentStage"]
    }
    
    convenience init(userId: String) {
        self.init()
        id = userId + "@\(Date().timeIntervalSince1970)"
    }
    
    convenience init(userId: String, accountName: String, pubKey: String, from: CreateKeyMode) {
        self.init()
        id = userId + "@\(Date().timeIntervalSince1970)"
        name = accountName
        ownerKey = pubKey
        activeKey = pubKey
        _keyFrom = from.rawValue
    }
    
    func changeAccountInfo(accountName: String, pubKey: String, from: CreateKeyMode) {
        DB.shared.safeWrite {
            name = accountName
            ownerKey = pubKey
            activeKey = pubKey
            _keyFrom = from.rawValue
        }
    }
    
    func addInvoice(creator: String, memo: String, total: String, created: Double) {
        DB.shared.safeWrite {
            self.creator = creator
            self.memo = memo
            self.total = total
            self.created = created
        }
    }
    
}






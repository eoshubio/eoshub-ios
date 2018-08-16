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
    @objc dynamic var completed: Bool = false
    @objc dynamic var total: String = ""
    @objc dynamic var memo: String = ""
    @objc dynamic var created: Double = 0
    @objc dynamic var creator: String = ""
    @objc dynamic var cpu = ""
    @objc dynamic var net = ""
    @objc dynamic var ram = ""
    @objc dynamic var expireTime: Double = 3600
    
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
    
    func addInvoice(invoice: Invoice) {
        DB.shared.safeWrite {
            self.completed = invoice.completed
            self.total = invoice.totalEOS.stringValue
            self.memo = invoice.memo
            self.created = invoice.createdAt
            self.creator = invoice.creator
            self.cpu = invoice.cpu.stringValue
            self.net = invoice.net.stringValue
            self.ram = "\(invoice.ram) Bytes"
            self.expireTime = 3600
        }
    }
    
}






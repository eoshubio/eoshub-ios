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
    @objc dynamic var _ownerKeyFrom: String = ""
    @objc dynamic var _activeKeyFrom: String = ""
    
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
    
    var ownerKeyFrom: CreateKeyMode {
        return CreateKeyMode(rawValue: _ownerKeyFrom) ?? .none
    }
    
    var activeKeyFrom: CreateKeyMode {
        return CreateKeyMode(rawValue: _activeKeyFrom) ?? .none
    }
    
    enum Stage: Int {
        case prepare, accountCheck, invoice, expired, completed
    }
    
    var currentStage: Stage {
        var stage: Stage = .prepare
        
        let accountChecked = (name.count > 0 && ownerKey.count > 0 && activeKey.count > 0)
        let invoice = (creator.count > 0 && memo.count > 0 && total.count > 0)
        let expired = created + expireTime < Date().timeIntervalSince1970 && created > 0
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
    
    var expireHour: Int {
        return Int(expireTime / 3600.0)
    }
    
    var isExpired: Bool {
        return created + expireTime < Date().timeIntervalSince1970 && completed == false
    }
    
    override static func ignoredProperties() -> [String] {
        return ["currentStage", "ownerKeyFrom", "activeKeyFrom", "expireHour", "isExpired"]
    }
    
    convenience init(userId: String) {
        self.init()
        id = userId + "@\(Date().timeIntervalSince1970)"
    }
    
    convenience init(userId: String, accountName: String, ownerKey: String, ownerKeyFrom: CreateKeyMode, activeKey: String, activeKeyFrom: CreateKeyMode) {
        self.init()
        self.id = userId + "@\(Date().timeIntervalSince1970)"
        self.name = accountName
        self.ownerKey = ownerKey
        self.activeKey = activeKey
        self._ownerKeyFrom = ownerKeyFrom.rawValue
        self._activeKeyFrom = activeKeyFrom.rawValue
    }
    
    func changeAccountInfo(accountName: String, ownerKey: String, ownerKeyFrom: CreateKeyMode, activeKey: String, activeKeyFrom: CreateKeyMode) {
        DB.shared.safeWrite {
            self.name = accountName
            self.ownerKey = ownerKey
            self.activeKey = activeKey
            self._ownerKeyFrom = ownerKeyFrom.rawValue
            self._activeKeyFrom = activeKeyFrom.rawValue
        }
    }
    
    func clearAccountInfo() {
        DB.shared.safeWrite {
            self.name = ""
            self.ownerKey = ""
            self.activeKey = ""
            self._ownerKeyFrom = ""
            self._activeKeyFrom = ""
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
            self.expireTime = Double(invoice.expireTime)
        }
    }
    
    func clearInvoice() {
        DB.shared.safeWrite {
            self.completed = false
            self.total = ""
            self.memo = ""
            self.created = 0
            self.creator = ""
            self.cpu = ""
            self.net = ""
            self.ram = ""
            self.expireTime = 3600
        }
    }
    
}






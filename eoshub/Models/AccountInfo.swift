//
//  AccountInfo.swift
//  eoshub
//
//  Created by kein on 2018. 7. 14..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class AccountInfo: DBObject, EOSAccountViewModel, Mergeable {
    
    @objc dynamic var account: String = ""
    @objc dynamic var pubKey: String = ""
    @objc dynamic var permission: String = ""
    
    var totalEOS: Double {
        return availableEOS + stakedEOS + refundingEOS
    }
    
    @objc dynamic var availableEOS: Double = 0
    @objc dynamic var stakedEOS: Double = 0
    @objc dynamic var cpuStakedEOS: Double = 0
    @objc dynamic var netStakedEOS: Double = 0
    @objc dynamic var ramBytes: Int64 = 0
    @objc dynamic var usedCPU: Int64 = 0
    @objc dynamic var usedNet: Int64 = 0
    @objc dynamic var usedRam: Int64 = 0
    @objc dynamic var maxCPU: Int64 = 0
    @objc dynamic var maxNet: Int64 = 0
    @objc dynamic var maxRam: Int64 = 0
    
    @objc dynamic var refundingEOS: Double = 0
    @objc dynamic var refundRequestTime: TimeInterval = 0
    @objc dynamic var refundingTime: TimeInterval = 0
    
    @objc dynamic var ownerMode: Bool = false
    
    
    
    //votes info
    let _votedProducers = List<RealmString>()
    
    var votedProducers: [String] {
        get {
            return _votedProducers.map { $0.stringValue }
        }
        set {
            _votedProducers.removeAll()
            _votedProducers.append(objectsIn: newValue.map({ RealmString(value: $0) }))
        }
    }
    
    //tokens
    let _tokens = List<RealmString>()
    
    var tokens: [Currency] {
        get {
            return _tokens.map { $0.stringValue }.compactMap(Currency.create)
        }
        set {
            _tokens.removeAll()
            _tokens.append(objectsIn: newValue.map({ RealmString(value: $0.rawValue) }))
        }
    }
    
    var availableRamBytes: Int64 {
        return ramBytes - usedRam
    }
    
    var usedCPURatio: Float {
        return Float(usedCPU) / Float(maxCPU)
    }
    
    var usedNetRatio: Float {
        return Float(usedNet) / Float(maxNet)
    }
    
    var usedRAMRatio: Float {
        return Float(usedRam) / Float(maxRam)
    }
    
    override static func ignoredProperties() -> [String] {
        return ["votedProducers", "tokens", "availableRamBytes", "usedCPURatio", "usedNetRatio", "usedRAMRatio"]
    }
    
    convenience init(with eosioAccount: Account, storedKey: String) {
        self.init()
        self.id = eosioAccount.name
        account = eosioAccount.name
        
        availableEOS = eosioAccount.liquidBalance.quantity
        stakedEOS = eosioAccount.resources.staked
        
        if let producers = eosioAccount.voterInfo?.producers {
            votedProducers = producers
        }
        
        refundingEOS = eosioAccount.refundInfo?.totalAmount ?? 0
        
        if let requestTime = eosioAccount.refundInfo?.requestedTime {
            refundRequestTime = requestTime
            refundingTime = requestTime + 72 * 60 * 60//72hour
        }
        
        cpuStakedEOS = eosioAccount.resources.cpuWeight.quantity
        
        netStakedEOS = eosioAccount.resources.netWeight.quantity
        
        ramBytes = eosioAccount.ramQuota
        
        usedCPU = eosioAccount.cpuLimit.used
        maxCPU = eosioAccount.cpuLimit.max
        
        usedNet = eosioAccount.netLimit.used
        maxNet = eosioAccount.netLimit.max
        
        usedRam = eosioAccount.ramUsage
        maxRam = eosioAccount.ramQuota
        
        ownerMode = false
        
        if storedKey.count > 0 {
            
            eosioAccount.permissions.forEach { (auth) in
                //check owner
                if let matchKey = auth.keys.filter({$0.key == storedKey}).first {
                    pubKey = matchKey.key
                    permission = auth.permission.value
                    ownerMode = true
                }
            }
        }
        
        
    }
    
    func mergeChanges(from newObject: AccountInfo) {
        pubKey = newObject.pubKey
        permission = newObject.permission
        availableEOS = newObject.availableEOS
        stakedEOS = newObject.stakedEOS
        ownerMode = newObject.ownerMode
        votedProducers = newObject.votedProducers
        refundingEOS = newObject.refundingEOS
        refundRequestTime = newObject.refundRequestTime
        refundingTime = newObject.refundingTime
        cpuStakedEOS = newObject.cpuStakedEOS
        netStakedEOS = newObject.netStakedEOS
        ramBytes = newObject.ramBytes
        
        usedCPU = newObject.usedCPU
        maxCPU = newObject.maxCPU
        usedNet = newObject.usedNet
        maxNet = newObject.maxNet
        usedRam = newObject.usedRam
        maxRam = newObject.maxRam
        
        
        _tokens.removeAll()
        _tokens.append(objectsIn: newObject._tokens)
    }
    
    func addToken(currency: Currency) {
        _tokens.append(RealmString(value: currency.rawValue))
    }
    
    func addTokens(currency: [Currency]) {
        tokens = currency
    }
    
}

extension AccountInfo: CellType {
    var nibName: String {
        return "WalletCell"
    }
}

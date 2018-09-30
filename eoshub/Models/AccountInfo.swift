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
    
    let _ownerkeys = List<RealmString>()
    let _activekeys = List<RealmString>()
    
    var ownerKeys: [String] {
        return _ownerkeys.map {$0.stringValue}
    }
    
    var activeKeys: [String] {
        return _activekeys.map {$0.stringValue}
    }
    
    var allKeys: [String] {
        return ownerKeys + activeKeys
    }
    
    @objc dynamic var _storedKeyJSON: String = ""
    
    var storedKeys: [StoredKey] {
        guard let json = JSON.createJSON(from: _storedKeyJSON),
              let storedKeyJSON = json.arrayJson(for: "storedKeys") else { return [] }
        
        return storedKeyJSON.compactMap(StoredKey.init)
    }
    
    var highestPriorityKey: StoredKey? {
        let keys = storedKeys
        let ownerKeys = keys.filter({$0.permission == .owner})
        if ownerKeys.count > 0 {
            if let seKey = ownerKeys.filter({$0.repo == .secureEnclave}).first {
                return seKey
            } else {
                return ownerKeys.first
            }
        }
        
        let activeKeys = keys.filter({$0.permission == .active})
        if activeKeys.count > 0 {
            if let seKey = activeKeys.filter({$0.repo == .secureEnclave}).first {
                return seKey
            } else {
                return activeKeys.first
            }
        }
        return nil
    }
    
    @objc dynamic var hasRepoKeychain = false //has private key in keychain
    @objc dynamic var hasRepoSE = false //has private key in Secure enclave
    
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
    
    var hasRefundedEOS: Bool {
        return  Date().timeIntervalSince1970 - refundingTime > 0 && refundingEOS > 0
    }
    
    
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
        return maxCPU > 0 ? Float(usedCPU) / Float(maxCPU) : 0
    }
    
    var usedNetRatio: Float {
        return maxNet > 0 ? Float(usedNet) / Float(maxNet) : 0
    }
    
    var usedRAMRatio: Float {
        return maxRam > 0 ? Float(usedRam) / Float(maxRam) : 0
    }
    
    override static func ignoredProperties() -> [String] {
        return ["votedProducers", "tokens", "availableRamBytes", "usedCPURatio", "usedNetRatio", "usedRAMRatio", "storedAuthority"]
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
        
        let okeys = eosioAccount.permissions
                    .filter {$0.permission == Permission.owner}
                    .map { $0.keys.map({ $0.key}) }.joined()
                    .map {RealmString(value: $0)}
        
        _ownerkeys.append(objectsIn: okeys)
        
        let akeys = eosioAccount.permissions
                    .filter {$0.permission == Permission.active}
                    .map { $0.keys.map({ $0.key}) }.joined()
                    .map {RealmString(value: $0)}
        
        _activekeys.append(objectsIn: akeys)
        
        var storedKeys: [StoredKey] = []
        
        let permissions = eosioAccount.permissions.map({$0.seperated}).joined()
        
        permissions.forEach { (auth) in
            guard let key = auth.keys.first else { return }
            let repo = Security.shared.getKeyRepository(pub: key.key)
            if repo != .none {
                
                if repo == .secureEnclave {
                    hasRepoSE = true
                } else if repo == .iCloudKeychain {
                    hasRepoKeychain = true
                }
                storedKeys.append(StoredKey(eosioKey: key, permission: auth.permission, repo: repo))
                ownerMode = true
            }
        }
        
        //Select the public key to use.
        
        if let seKey = storedKeys.filter({$0.repo == .secureEnclave}).first {
            //1. find in secure enclave
            pubKey = seKey.eosioKey.key
            permission = seKey.permission.value
        } else if let keychainKey = storedKeys.filter({$0.repo == .iCloudKeychain }).first {
            //2. find in iCloud keychains
            pubKey = keychainKey.eosioKey.key
            permission = keychainKey.permission.value
        } else {
            Log.e("Invalid state")
        }
        
        if let storedKeyJSON = ["storedKeys": storedKeys.compactMap({$0.json})].stringValue {
            _storedKeyJSON = storedKeyJSON
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
        
        _votedProducers.removeAll()
        _votedProducers.append(objectsIn: newObject._votedProducers)
        
        _tokens.removeAll()
        _tokens.append(objectsIn: newObject._tokens)
        
        _ownerkeys.removeAll()
        _ownerkeys.append(objectsIn: newObject._ownerkeys)
        
        _activekeys.removeAll()
        _activekeys.append(objectsIn: newObject._activekeys)
        
        hasRepoSE = newObject.hasRepoSE
        hasRepoKeychain = newObject.hasRepoKeychain
        
        _storedKeyJSON = newObject._storedKeyJSON
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

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
    var totalEOS: Double {
        return availableEOS + stakedEOS
    }
    
    @objc dynamic var availableEOS: Double = 0
    @objc dynamic var stakedEOS: Double = 0
    @objc dynamic var cpuStakedEOS: Double = 0
    @objc dynamic var netStakedEOS: Double = 0
    @objc dynamic var ramBytes: Int64 = 0
    @objc dynamic var usedRam: Int64 = 0
    
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

    override static func ignoredProperties() -> [String] {
        return ["votedProducers", "tokens", "availableRamBytes"]
    }
    
    convenience init(with eosioAccount: Account, isOwner: Bool) {
        self.init()
        self.id = eosioAccount.name
        account = eosioAccount.name
        pubKey = eosioAccount.permissions.first?.keys.first?.key ?? ""
        availableEOS = eosioAccount.liquidBalance.quantity
        stakedEOS = eosioAccount.resources.staked
        ownerMode = isOwner
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
        
        ramBytes = eosioAccount.resources.ramBytes
        
        usedRam = eosioAccount.ramUsage
        
    }
    
    func mergeChanges(from newObject: AccountInfo) {
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
        usedRam = newObject.usedRam
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

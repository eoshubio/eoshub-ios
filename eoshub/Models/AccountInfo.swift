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

class AccountInfo: DBObject, EOSAccountViewModel {
    
    @objc dynamic var account: String = ""
    @objc dynamic var pubKey: String = ""
    var totalEOS: Double {
        return availableEOS + stakedEOS
    }
    @objc dynamic var availableEOS: Double = 0
    @objc dynamic var stakedEOS: Double = 0
    
    //TODO: implement
    @objc dynamic var refundingEOS: Double = 0
    @objc dynamic var refundingRemainTime: TimeInterval = 0
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
            return _tokens.map { $0.stringValue }.compactMap(Currency.init)
        }
        set {
            _tokens.removeAll()
            _tokens.append(objectsIn: newValue.map({ RealmString(value: $0.currency) }))
        }
    }
    
    override static func ignoredProperties() -> [String] {
        return ["votedProducers", "tokens"]
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
    }
    
    func addToken(currency: Currency) {
        _tokens.append(RealmString(value: currency.currency))
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

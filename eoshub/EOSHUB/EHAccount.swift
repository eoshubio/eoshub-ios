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

class EHAccount: DBObject, Mergeable {
    
    @objc dynamic var account: String = ""
    
    @objc dynamic var publicKey: String = ""
    
    @objc dynamic var created: TimeInterval = 0
    
    @objc dynamic var owner: Bool = true
    
    fileprivate var _tokens = List<RealmString>()
    
    var tokens: [Token] {
        get {
            return _tokens.compactMap { Token(with: $0.stringValue) }
        }
        set {
            _tokens.removeAll()
            _tokens.append(objectsIn: newValue.map({ RealmString(value: $0.stringValue) }))
        }
    }
    
    override static func ignoredProperties() -> [String] {
        return ["tokenSymbols"]
    }
    
    convenience init(account: String, publicKey: String, owner: Bool) {
        self.init()
        self.id = account
        self.account = account
        self.publicKey = publicKey
        self.owner = owner
        created = Date().timeIntervalSince1970
 
    }
    
    func addPreferToken(token: Token) {
        _tokens.append(RealmString(value: token.stringValue))
    }
    
    func addPreferTokens(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func mergeChanges(from newObject: EHAccount) {
        account = newObject.account
        publicKey = newObject.publicKey
        created = newObject.created
        owner = newObject.owner
        _tokens = newObject._tokens
        
        
    }
}


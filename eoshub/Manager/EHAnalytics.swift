//
//  EHAnalytics.swift
//  eoshub
//
//  Created by kein on 2018. 8. 25..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import Firebase

class Event {
    let name: String
    var params: [String: NSObject] = [:]
    
    init(name: String) {
        self.name = name
    }
    
    init(name: String, params: [String: NSObject]) {
        self.name = name
        self.params = params
    }
    
    func addParam(key: String, value: NSObject) {
        params[key] = value
    }
    
}



enum EHEvent {
    case transfer(token: Token)
    case addToken(token: Token)
    case vote
    case delegate_bw
    case undelegate_bw
    case buy_ram
    case sell_ram
    case create_account(CreateKeyMode, CreateKeyMode)
    case import_account
    case interest_account
    case restore_account
    case try_create_account1
    case try_create_account2
    case try_create_account3
    case try_import_account
    case try_intrest_account
    case try_restore_account
}

extension EHEvent {
    var params: Event {
        switch self {
        case .transfer(let token):
            return Event(name: "transfer", params: ["token" : token.stringValue as NSString])
        case .addToken(let token):
            return Event(name: "addToken", params: ["token" : token.stringValue as NSString])
        case .vote:
            return Event(name: "vote")
        case .delegate_bw:
            return Event(name: "delegate_bw")
        case .undelegate_bw:
            return Event(name: "undelegate_bw")
        case .buy_ram:
            return Event(name: "buy_ram")
        case .sell_ram:
            return Event(name: "sell_ram")
        case .create_account(let owner, let active):
            return Event(name: "create_account", params: ["owner" : owner.rawValue as NSString,
                                                          "active": active.rawValue as NSString])
        case .import_account:
            return Event(name: "import_account")
        case .interest_account:
            return Event(name: "interest_account")
        case .restore_account:
            return Event(name: "restore_account")
        case .try_create_account1:
            return Event(name: "try_create_account1")
        case .try_create_account2:
            return Event(name: "try_create_account2")
        case .try_create_account3:
            return Event(name: "try_create_account3")
        case .try_import_account:
            return Event(name: "try_import_account")
        case .try_intrest_account:
            return Event(name: "try_intrest_account")
        case .try_restore_account:
            return Event(name: "try_restore_account")
        }
    }
}

struct EHAnalytics {
    
    static func trackEvent(event: EHEvent) {
        let param = event.params
        Analytics.logEvent(param.name, parameters: param.params)
    }
    
    static func trackScreen(name: String, classOfFlow: AnyClass) {
        Analytics.setScreenName(name, screenClass: String(describing: classOfFlow))
    }
    
    static func setUserProperties() {
        let infos = AccountManager.shared.ownerInfos
        
        let total = infos.map({$0.totalEOS}).reduce(0,+)
        
        Analytics.setUserProperty("\(total)", forName: "total_eos_quantity")
        
        let ownerMode = infos.count > 0
    
        Analytics.setUserProperty("\(ownerMode)", forName: "owner_mode")
    }
    
}

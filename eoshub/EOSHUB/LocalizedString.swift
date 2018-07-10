//
//  LocalizedString.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation


struct LocalizedString {
    struct Intro {
        static let title = NSLocalizedString("intro.title", comment: "")
    }
    
    struct Login {
        static let facebook = NSLocalizedString("login.facebook", comment: "")
        static let kakao = NSLocalizedString("login.kakao", comment: "")
        static let google = NSLocalizedString("login.google", comment: "")
    }
    
    struct Term {
        static let title = NSLocalizedString("term.title", comment: "")
        static let goPrivacy = NSLocalizedString("term.goPrivacy", comment: "")
        static let privacyDesc = NSLocalizedString("term.privacyDesc", comment: "")
        static let start = NSLocalizedString("term.start", comment: "")
    }
    
    struct Setting {
        static let title = NSLocalizedString("setting.title", comment: "")
        static let security = NSLocalizedString("setting.security", comment: "")
        static let app = NSLocalizedString("setting.app", comment: "")
        static let wallet = NSLocalizedString("setting.wallet", comment: "")
        static let logout = NSLocalizedString("setting.logout", comment: "")
    }
    
    struct Wallet {
        static let send = NSLocalizedString("wallet.send", comment: "")
        static let receive = NSLocalizedString("wallet.receive", comment: "")
        static let available = NSLocalizedString("wallet.available", comment: "")
        static let staked = NSLocalizedString("wallet.staked", comment: "")
        static let refunding = NSLocalizedString("wallet.refunding", comment: "")
        
        static let priKey = NSLocalizedString("wallet.import.priKey", comment: "")
        static let pubKey = NSLocalizedString("wallet.find.pubKey", comment: "")
        
        struct Import {
            static let title = NSLocalizedString("wallet.import.title", comment: "")
            static let account = NSLocalizedString("wallet.import.account", comment: "")
            static let store = NSLocalizedString("wallet.import.store", comment: "")
            static let findAccount = NSLocalizedString("wallet.import.findAccount", comment: "")
            static let clickHere = NSLocalizedString("wallet.import.clickHere", comment: "")
        }
        
        struct Find {
            static let title = NSLocalizedString("wallet.find.title", comment: "")
            static let search = NSLocalizedString("wallet.find.search", comment: "")
            
        }
    }
    
    struct Common {
        static let paste = NSLocalizedString("common.paste", comment: "")
        static let copy = NSLocalizedString("common.copy", comment: "")
    }
    
}

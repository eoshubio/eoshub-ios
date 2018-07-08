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
    
    struct Setting {
        static let title = NSLocalizedString("setting.title", comment: "Settings")
        static let security = NSLocalizedString("setting.security", comment: "Security")
        static let app = NSLocalizedString("setting.app", comment: "App")
        static let wallet = NSLocalizedString("setting.wallet", comment: "Wallet")
        static let logout = NSLocalizedString("setting.logout", comment: "Logout")
        
    }
    
}

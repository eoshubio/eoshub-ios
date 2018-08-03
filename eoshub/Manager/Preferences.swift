//
//  Preferences.swift
//  eoshub
//
//  Created by kein on 2018. 7. 23..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation


class Preferences {
    static let shared = Preferences()
    

    var preferHost: String
    
    var lastRefreshTime: TimeInterval {
        didSet {
            defaults.set(lastRefreshTime, forKey: "lastRefreshTime")
        }
    }
    
    let defaults = UserDefaults(suiteName: "settings")!
    
    init() {
        preferHost = defaults.string(forKey: "preferHost") ?? Config.host
        
        lastRefreshTime = defaults.double(forKey: "lastRefreshTime")
    }
}

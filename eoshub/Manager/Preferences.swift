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
    

    var preferHost: String {
        didSet {
            defaults.set(preferHost, forKey: "preferHost")
        }
    }
    
    var lastRefreshTime: TimeInterval {
        didSet {
            defaults.set(lastRefreshTime, forKey: "lastRefreshTime")
        }
    }
    
    var preferCurrency: String {
        didSet {
            defaults.set(preferCurrency, forKey: "preferCurrency")
        }
    }
    
    let defaults = UserDefaults(suiteName: "settings")!
    
    init() {
        preferHost = defaults.string(forKey: "preferHost") ?? Config.host
        
        lastRefreshTime = defaults.double(forKey: "lastRefreshTime")
        
        if let storedCurrency = defaults.string(forKey: "preferCurrency") {
            preferCurrency = storedCurrency
        } else if Locale.current.currencyCode == Price.Currency.KRW.rawValue {
            preferCurrency = Price.Currency.KRW.rawValue
        } else {
            preferCurrency = Price.Currency.USD.rawValue
        }
    }
}

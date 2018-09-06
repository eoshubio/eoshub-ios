//
//  EOSHost.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 13..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

open class EOSHost {
    
    static let shared = EOSHost()
    
    var host: String = Preferences.shared.preferHost
    var version: String = "v1"
    
    var url: String {
        return host + "/" + version
    }
    
    var urlContainsHistory: String {
        return Config.mainHost + "/" + version
    }
}

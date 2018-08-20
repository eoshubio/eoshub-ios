//
//  URLs.swift
//  eoshub
//
//  Created by kein on 2018. 8. 20..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

struct URLs {
    static let secureEnclave =  "https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_in_the_secure_enclave"
    
    static var iCloundKeychain: String {
        //        https://support.apple.com/en-us/HT204085
        //        https://support.apple.com/ko-kr/HT204085
        var code = "en-us"
        if let lan = Locale.current.languageCode, let region = Locale.current.regionCode?.lowercased() {
            code = lan + "-" + region
        }
        let keyChainDoc = "https://support.apple.com/\(code)/HT204085"
        return keyChainDoc
    }
}

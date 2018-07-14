//
//  Security.swift
//  eoshub
//
//  Created by kein on 2018. 7. 13..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import KeychainSwift
import EllipticCurveKeyPair

class Security {
    static let shared = Security()
    
    
    func setPin(pin: String) {
        //TODO: Encrypt Pin
        KeychainSwift().set(pin, forKey: "eoshub.gate")
    }
    
    func validatePin(pin: String) -> Bool {
        //TODO: Decrypt PIN
        let existPin = KeychainSwift().get("eoshub.gate")
        return existPin == pin
    }
    
    func hasPin() -> Bool {
        return KeychainSwift().get("eoshub.gate") != nil
    }
    
    
    func getDBKeyData() -> Data {
        let dbKey = "eoshub.db.non-sensitive"
        if let loadedKey = KeychainSwift().getData(dbKey) {
            return loadedKey
        } else {
            //Generate RandomByte for DB Key (Non-Sensitive User data)
            let key = NSMutableData(length: 64)!
            _ = SecRandomCopyBytes(kSecRandomDefault, key.length, UnsafeMutableRawPointer(key.mutableBytes))
            let encryptedKeyData = key as Data
            //Add to KeyChain
            KeychainSwift().set(encryptedKeyData, forKey: dbKey)
            return encryptedKeyData
        }
    }
    
    func setEncryptedKey(pub: String, pri: String) {
        KeychainSwift().set(pri, forKey: pub)
    }
    
    func getEncryptedPrivateKey(pub: String) -> String? {
        return KeychainSwift().get(pub)
    }
    
}

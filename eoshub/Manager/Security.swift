//
//  Security.swift
//  eoshub
//
//  Created by kein on 2018. 7. 13..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import KeychainSwift
import RxSwift
import LocalAuthentication
import RNCryptor

class Security {
    static let shared = Security()
    
    let authorized = PublishSubject<Bool>()
    
    var needAuthentication: Bool = true
    
    var enableBioAuth: Bool
    
    init() {
        KeychainSwift().set(true, forKey: "eoshub.enableBioAuth")
        enableBioAuth = KeychainSwift().getBool("eoshub.enableBioAuth") ?? false
    }
    
    
    func setPin(pin: String) {
        KeychainSwift().set(pin, forKey: "eoshub.gate")
    }
    
    func setEnableBioAuth(on: Bool) {
        enableBioAuth = on
        KeychainSwift().set(on, forKey: "eoshub.enableBioAuth")
    }
    
    func validatePin(pin: String) -> Bool {
        let existPin = KeychainSwift().get("eoshub.gate")
        return existPin == pin
    }
    
    func hasPin() -> Bool {
        return KeychainSwift().get("eoshub.gate") != nil
    }
    
    func biometryType() -> LABiometryType {
        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)  {
            return context.biometryType
        }
        return .none
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
    
    func setEncryptedKey(pub: String, pri: String) -> Observable<Bool> {
        guard let pin = KeychainSwift().get("eoshub.gate") else {
            return Observable.error(EOSErrorType.cannotFoundPIN)
        }
        
        guard let priData = pri.data(using: .utf8)
            else { return Observable.error(EOSErrorType.invalidKeys) }
        
        let enPri = RNCryptor.encrypt(data: priData, withPassword: pin)
        
        let key = String(pub[3...])
        
        KeychainSwift().set(enPri, forKey: key)
        
        return Observable.just(true)
    }
    
    func getEncryptedPrivateKey(pub: String) -> String? {
        
        guard let pin = KeychainSwift().get("eoshub.gate") else {
            return nil
        }
        
        let key = String(pub[3...])
        
        guard let encryptedPriData = KeychainSwift().getData(key) else { return nil }
        
        guard let priData = try? RNCryptor.decrypt(data: encryptedPriData, withPassword: pin) else { return nil }
        
        let priKey = String(data: priData, encoding: .utf8)
        
        return priKey
    }
    
}

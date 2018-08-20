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
    
    var enableBioAuth: Bool {
        return KeychainSwift().getBool(bioAuthKey) ?? false
    }
    
  
    
    init() {
        
    }
    
    private func makeRandomSeed(count: Int) -> String {
        var result = ""
        for _ in 0..<count {
            let randomChr = UInt8(arc4random() % 255)
            result += String(format: "%02X", randomChr)
        }
        return result
    }
    
    func setPin(pin: String) {
        KeychainSwift().set(pin, forKey: gateKey)
    }
    
    func setEnableBioAuth(on: Bool) {
        
        KeychainSwift().set(on, forKey: bioAuthKey)
    }
    
    func validatePin(pin: String) -> Bool {
        let existPin = KeychainSwift().get(gateKey)
        return existPin == pin
    }
    
    func hasPin() -> Bool {
        return KeychainSwift().get(gateKey) != nil
    }
    
    private var seed: String {
        if let seed =  KeychainSwift().get(seedKey) {
            return seed
        } else {
            let seed = makeRandomSeed(count: 32)
            KeychainSwift().set(seed, forKey: seedKey)
            return seed
        }
        
    }
    
    func biometryType() -> LABiometryType {
        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)  {
            return context.biometryType
        }
        return .none
    }
    
    
    func getDBKeyData() -> Data {
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
 
        guard let priData = pri.data(using: .utf8)
            else { return Observable.error(EOSErrorType.invalidKeys) }
        
        let enPri = RNCryptor.encrypt(data: priData, withPassword: seed)
        
        var key = prefix
        if pub.hasPrefix("PUB_R1_") {
            key += String(pub[7...])
        } else {
            key += String(pub[3...])
        }
        
        KeychainSwift().set(enPri, forKey: key)
        
        return Observable.just(true)
    }
    
    func getEncryptedPrivateKey(pub: String) -> String? {

        var key = prefix
        if pub.hasPrefix("PUB_R1_") {
            key += String(pub[7...])
        } else {
            key += String(pub[3...])
        }
        
        guard let encryptedPriData = KeychainSwift().getData(key) else { return nil }
        
        guard let priData = try? RNCryptor.decrypt(data: encryptedPriData, withPassword: seed) else { return nil }
        
        let priKey = String(data: priData, encoding: .utf8)
        
        return priKey
    }
    
    func getKeyRepository(pub: String) -> KeyRepository {
        return _getKeyRepository(pub: pub)
    }
    
    private func _getKeyRepository(pub: String) -> KeyRepository {
        
        if let pri = getEncryptedPrivateKey(pub: pub) {
            if pri.hasPrefix("se") {
                return .secureEnclave
            } else {
                return .iCloundKeychain
            }
        } else {
            return .none
        }
    }
    
    
    
    //MARK: Keys
    func generatePrivateKeyAndSaveLabel() -> String? {
        
        let label = "se." + prefix + "\(Date().timeIntervalSince1970)"
        
        guard let accessControl = SecureEnclaveManager.accessControl() else {
            Log.e("cannot make access control")
            return nil
        }
        
        guard let eosPubKey = SecureEnclaveManager.generateKeyPair(privateKeyLabel: label, accessControl: accessControl) else {
            Log.e("cannot generate keypair")
            return nil
        }

        _ = setEncryptedKey(pub: eosPubKey, pri: label)
        
        return eosPubKey
    }
    
}

extension Security {
    fileprivate var prefix: String {
        return UserManager.shared.userId+"@"
    }
    
    fileprivate var seedKey: String {
        return prefix + "eoshub.seed"
    }
    
    fileprivate var gateKey: String {
        return prefix + "eoshub.gate"
    }
    
    fileprivate var bioAuthKey: String {
        return prefix + "eoshub.enableBioAuth"
    }
    
    fileprivate var dbKey: String {
        return prefix + "eoshub.db.non-sensitive"
    }
}


enum KeyRepository {
    case iCloundKeychain, secureEnclave, none
}




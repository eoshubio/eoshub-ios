//
//  Wallet.swift
//  eoshub
//
//  Created by kein on 2018. 7. 14..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation



class Wallet {
    
    private let pubKey: String
    
    init(account: EHAccount) {
        self.pubKey = account.publicKey
    }
    
    init(key: String) {
        self.pubKey = key
    }
    
    func sign(txn: SignedTransaction, cid: String) {

        let packedBytes = txn.digest(cid: cid, capacity: 255)
        
        let priKey = Security.shared.getEncryptedPrivateKey(pub: pubKey)
        
        let key = EOS_Key_Encode.getRandomBytesData(withWif: priKey)
        
        
        let h = Sha256(data: Data(bytes: packedBytes))
        
        if let sig = Crypto.sign(withPrivateKey: key, hash: h!.mHashBytesData) {
            txn.signatures.append(sig)
        }
        
    }
    
}

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
  
        guard let priKey = Security.shared.getEncryptedPrivateKey(pub: pubKey) else {
            Log.e("cannot find private key in keychain for \(pubKey)")
            return
        }
        
        guard let digest = Sha256(data: Data(bytes: packedBytes))!.mHashBytesData else {
            Log.e("fail to create digest")
            return
        }
        
        if priKey.hasPrefix("eoshub") {
            //SE
            signSE(txn: txn, priKeyLabel: priKey, digest: digest)
        } else {
            signK1(txn: txn, priKey: priKey, digest: digest)
        }
        
        //TODO: supports R1
        
    }
    
    private func signK1(txn: SignedTransaction, priKey: String, digest: Data) {
        
        let key = EOS_Key_Encode.getRandomBytesData(withWif: priKey)
        
        if let sig = Crypto.sign(withPrivateKey: key, hash: digest) {
            txn.signatures.append(sig)
        }
    }
    
    private func signSE(txn: SignedTransaction, priKeyLabel: String, digest: Data) {
        
        if let sig = SecureEnclaveManager.trySignDigest(digest: digest, privateKeyLabel: priKeyLabel) {
            txn.signatures.append(sig)
        }
        
    }
    
    private func swapUInt16Data(data : Data) -> Data {
        var mdata = data // make a mutable copy
        let count = data.count / MemoryLayout<UInt16>.size
        mdata.withUnsafeMutableBytes { (i16ptr: UnsafeMutablePointer<UInt16>) in
            for i in 0..<count {
                i16ptr[i] =  i16ptr[i].byteSwapped
            }
        }
        return mdata
    }
}










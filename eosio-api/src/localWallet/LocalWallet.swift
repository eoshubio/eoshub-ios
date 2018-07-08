//
//  LocalWallet.swift
//  eosio-api
//
//  Created by kein on 2018. 7. 4..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

class LocalWallet {
    
    static let shared = LocalWallet()
    
    func sign(txn: SignedTransaction, pubKeys: [String], cid: String) {
        
    }
    
    
    //TODO: internal -> private
    func sign(txn: SignedTransaction, priKey: String, cid: String) {

        let packedBytes = digest(txn: txn, cid: cid, capacity: 255)
//        let packed255 = digest(txn: txn, cid: cid, capacity: 255)
//        let packed512 = digest(txn: txn)
//
//        print("==255")
//        print(packed255)
//        print("==512")
//        print(packed512)
        
//        let pub = EOS_Key_Encode.eos_publicKey_(with_wif: priKey)
//
//        let varifiy = EOS_Key_Encode.validateWif(priKey)
//        
        let key = EOS_Key_Encode.getRandomBytesData(withWif: priKey)
        
//        let pubKey = EOS_Key_Encode.eos_publicKey_(with_wif: priKey)!
        
        let h = Sha256(data: Data(bytes: packedBytes))
        
        
        if let sig = Crypto.sign(withPrivateKey: key, hash: h!.mHashBytesData) {
            txn.signatures.append(sig)            
        }
        
        
    }
    
    
    func digest(txn: SignedTransaction, cid: String? = nil, capacity: Int = 512) -> [UInt8] {
        let pack = Pack(with: capacity)
        if let cid = cid {
            pack.put(bytes: cid.hexToBytes)
        }
        
        txn.serialize(pack: pack)
        
        let emptySha = [UInt8](repeating: 0x00, count: 32)
        pack.put(bytes: emptySha)
        
        return pack.packedBytes
    }

    func getDummyData() -> [UInt8] {
        return [0x03, 0x8f, 0x4b,0x0f,0xc8,0xff,0x18,0xa4,0xf0,
         0x84,0x2a,0x8f,0x05,0x64,0x61,0x1f,0x6e,0x96,0xe8,
         0x53,0x59,0x01,0xdd,0x45,0xe4,0x3a,0xc8,0x69,
         0x1a,0x1c,0x4d,0xca,0x49,0x16,0x40,0x5b,0xa6,0x54,
         0xa3,0xfa,0x21,0xc7,0x00,0x00,0x00,
         0x00,
         0x01,
         0x00,
         0xa6,
         0x82,
         0x34,
         0x03,
         0xea,
         0x30,
         0x55,
         0x00,
         0x00,
         0x00,
         0x57,
         0x2d,
         0x3c,
         0xcd,
         0xcd,
         0x01,
         0x00,
         0x40,
         0xc6,
         0x2a,
         0x1f,
         0xdd,
         0x30,
         0x55,
         0x00,
         0x00,
         0x00,
         0x00,
         0xa8,
         0xed,
         0x32,
         0x32,
         0x21,
         0x00,
         0x40,
         0xc6,
         0x2a,
         0x1f,
         0xdd,
         0x30,
         0x55,
         0x10,
         0x42,
         0xb0,
         0xd6,
         0x1e,
         0xdd,
         0x30,
         0x55,
         0x90,
         0x5f,
         0x01,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x04,
         0x45,
         0x4f,
         0x53,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00,
         0x00]
    }
    
    func getDummyKey() -> Data {
        let key: [UInt8] = [147
            ,13
            ,107
            ,120
            ,198
            ,172
            ,141
            ,127
            ,248
            , 213
            , 92
            , 228
            , 58
            , 158
            , 245
            , 147
            , 31
            , 191
            , 95
            , 238
            , 195
            , 255
            , 185
            , 32
            , 203
            , 91
            , 120
            , 81
            , 99
            , 87
            , 28]
        
        return Data(bytes: key)
        
    }
}



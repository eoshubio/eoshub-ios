//
//  Wallet.swift
//  eoshub
//
//  Created by kein on 2018. 7. 14..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift



class Wallet {
    
    fileprivate weak var authParentVC: UIViewController?
    
    private let pubKey: String
    
    init(account: EHAccount) {
        self.pubKey = account.publicKey
    }
    
    init(key: String, parent: UIViewController) {
        self.pubKey = key
        authParentVC = parent
    }
    
    
    func rx_sign(txn: SignedTransaction, cid: String) -> Observable<SignedTransaction> {
         guard let priKey = Security.shared.getEncryptedPrivateKey(pub: pubKey) else {
            Log.e("cannot find private key in keychain for \(pubKey)")
            return Observable.error(WalletError.noValidPrivatekey)
        }
        
        
        if priKey.hasPrefix("se") == false {
            //authentication self
            guard let vc = authParentVC else { return Observable.error(WalletError.authorizationViewisNotSet)}
            
            return authentication(showAt: vc)
                .flatMap({ [weak self] (authorized) -> Observable<SignedTransaction> in
                    if authorized {
                        self?.sign(txn: txn, cid: cid, priKey: priKey)
                        if txn.signatures.count > 0 {
                            return Observable.just(txn)
                        } else {
                            return Observable.error(WalletError.failedToSignature)
                        }
                    } else {
                        return Observable.error(WalletError.cancelled)
                    }
                })
            
        } else {
            sign(txn: txn, cid: cid, priKey: priKey)
            if txn.signatures.count > 0 {
                return Observable.just(txn)
            } else {
                return Observable.error(WalletError.failedToSignature)
            }
        }
    }
    
    private func authentication(showAt vc: UIViewController) -> Observable<Bool> {
        let config = FlowConfigure(container: vc, parent: nil, flowType: .modal)
        let fc = ValidatePinFlowController(configure: config)
        fc.start(animated: true)
        
        return fc.validated.asObservable()
    }
    
    private func sign(txn: SignedTransaction, cid: String, priKey: String) {
        let packedBytes = txn.digest(cid: cid)
        
//        guard let digest = Sha256(data: Data(bytes: packedBytes))!.mHashBytesData else {
//            Log.e("fail to create digest")
//            return
//        }
        
        let packedData = Data(bytes: packedBytes)
        
        let digest = Sha256.digest(data: packedData)
        
        if Validator.validatePrivateKeyR1(label: priKey) {
            //SE
            signSE(txn: txn, priKeyLabel: priKey, digest: digest)
        } else if Validator.validatePrivateKeyK1(key: priKey) {
            signK1(txn: txn, priKey: priKey, digest: digest)
        } else {
            Log.e("failed to find valid private key type")
            return
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

}










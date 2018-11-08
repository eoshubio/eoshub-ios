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
    
    private var skipAuth: Bool = false
    
    init(account: EHAccount) {
        self.pubKey = account.publicKey
    }
    
    init(key: String, parent: UIViewController) {
        self.pubKey = key
        authParentVC = parent
    }
    
    init(key: String, skipAuth: Bool) {
        self.pubKey = key
        self.skipAuth = skipAuth
    }
    
    
    func rx_sign(txn: SignedTransaction, cid: String) -> Observable<SignedTransaction> {
         guard let priKey = Security.shared.getEncryptedPrivateKey(pub: pubKey) else {
            Log.e("cannot find private key in keychain for \(pubKey)")
            return Observable.error(WalletError.noValidPrivatekey)
        }
        
        if priKey.hasPrefix("se") == false {
            //authentication self
            if skipAuth {
                return Wallet.sign(txn: txn, cid: cid, priKey: priKey)
            } else {
                guard let vc = authParentVC else { return Observable.error(WalletError.authorizationViewisNotSet)}
                WaitingView.shared.stop()
                
                return authentication(showAt: vc)
                    .flatMap({ (authorized) -> Observable<SignedTransaction> in
                        
                        if authorized {
                            WaitingView.shared.start()
                            
                            return Wallet.sign(txn: txn, cid: cid, priKey: priKey)
                        } else {
                            return Observable.error(WalletError.canceled)
                        }
                    })
            }
        } else {
            return Wallet.sign(txn: txn, cid: cid, priKey: priKey)
        }
    }
    
    private func authentication(showAt vc: UIViewController) -> Observable<Bool> {
        let config = FlowConfigure(container: vc, parent: nil, flowType: .modal)
        let fc = ValidatePinFlowController(configure: config)
        fc.start(animated: true)
        
        return fc.validated.asObservable()
    }
    
    private static func sign(txn: SignedTransaction, cid: String, priKey: String) -> Observable<SignedTransaction> {
        let packedBytes = txn.digest(cid: cid)
        
        let packedData = Data(bytes: packedBytes)
        
        let digest = Sha256.digest(data: packedData)
        
        if Validator.validatePrivateKeyR1(label: priKey) {
            //SE
            return signSE(priKeyLabel: priKey, digest: digest)
                .flatMap({ (sig) -> Observable<SignedTransaction> in
                    txn.signatures.append(sig)
                    return Observable.just(txn)
                })
        } else if Validator.validatePrivateKeyK1(key: priKey) {
            return signK1(priKey: priKey, digest: digest)
                .flatMap({ (sig) -> Observable<SignedTransaction> in
                    txn.signatures.append(sig)
                    return Observable.just(txn)
                })
        } else {
            Log.e("failed to find valid private key type")
            return Observable.error(EOSHubError.invalidState)
        }
        //TODO: supports R1
    }
    
    private static func signK1(priKey: String, digest: Data) -> Observable<String> {
        
        let key = EOS_Key_Encode.getRandomBytesData(withWif: priKey)
        
        
        if let sig = Crypto.sign(withPrivateKey: key, hash: digest) {
//            txn.signatures.append(sig)
            return Observable.just(sig)
        } else {
            return Observable.error(EOSHubError.failedToSignature)
        }
    }
    
    private static func signSE(priKeyLabel: String, digest: Data) -> Observable<String> {
        
        if let sig = SecureEnclaveManager.trySignDigest(digest: digest, privateKeyLabel: priKeyLabel) {
//            txn.signatures.append(sig)
            return Observable.just(sig)
        } else {
            return Observable.error(EOSHubError.failedToSignature)
        }
        
    }

}










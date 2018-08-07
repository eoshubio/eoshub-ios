//
//  ImportViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ImportViewController: TextInputViewController {
    
    var flowDelegate: ImportFlowEventDelegate?
    
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var txtPriKey: WhiteTextField!
    @IBOutlet fileprivate weak var lbWarningTitle: UILabel!
    @IBOutlet fileprivate weak var lbWarning: UILabel!
    @IBOutlet fileprivate weak var btnImport: UIButton!
//    @IBOutlet fileprivate weak var btnFindAccount: UIButton!
    
    deinit {
        Log.d("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .darkGray)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        lbTitle.text = LocalizedString.Wallet.Import.title
        btnImport.setTitle(LocalizedString.Wallet.Import.store, for: .normal)
        lbWarningTitle.text = LocalizedString.Create.Import.warningTitle
        lbWarning.text = LocalizedString.Create.Import.warning
        
        let txt = LocalizedString.Wallet.Import.findAccount
        let txtFindAccount = NSMutableAttributedString(string: txt,
        attributes: [NSAttributedStringKey.font: Font.appleSDGothicNeo(.regular).uiFont(12),
                     NSAttributedStringKey.foregroundColor: Color.darkGray.uiColor])
        
        if let clickRange = txt.range(of: LocalizedString.Wallet.Import.clickHere) {
            let clickNSRange = txt.nsRange(from: clickRange)
            txtFindAccount.addAttributes([NSAttributedStringKey.font : Font.appleSDGothicNeo(.bold).uiFont(12),
                                          NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue],
                                         range: clickNSRange)
        }
        
        
//        btnFindAccount.setAttributedTitle(txtFindAccount, for: .normal)
        
        txtPriKey.placeholder = LocalizedString.Wallet.priKey
        txtPriKey.delegate = self
        
        
    }
    
    private func bindActions() {
        
        
        
//        btnFindAccount.rx.singleTap
//            .bind { [weak self] in
//                guard let nc = self?.navigationController else { return }
//                self?.flowDelegate?.goFindAccount(from: nc)
//            }
//        .disposed(by: bag)
        
        btnImport.rx.singleTap
            .bind { [weak self] in
                self?.handleImportKey()
            }
            .disposed(by: bag)
                
        txtPriKey.rx.text.orEmpty
            .flatMap { (priKey) -> Observable<Bool> in
                return Observable.just(EOS_Key_Encode.validateWif(priKey))
            }
            .bind(to: btnImport.rx.isEnabled)
            .disposed(by: bag)
        
    }
    
    fileprivate func handleImportKey() {
        
        defer {
            view.endEditing(true)
        }
        
        //1. get public key from private key
        guard let priKey = txtPriKey.text else { return }
        
        guard let pubKey = EOS_Key_Encode.eos_publicKey_(with_wif: priKey) else { return }
        
        
        if let existAccount = AccountManager.shared.getAccount(pubKey: pubKey), existAccount.owner {
            Popup.present(style: Popup.Style.failed, description: "\(EOSErrorType.existAccount)")
        } else {
            if Reachability.isConnectedToNetwork() {
                RxEOSAPI.getAccountFromPubKey(pubKey: pubKey)
                    .flatMap({ (accountName) -> Observable<EHAccount> in
                        let account = EHAccount(account: accountName, publicKey: pubKey, owner: true)
                        
                        //2. save account with public Key
                        _ = Security.shared.setEncryptedKey(pub: pubKey, pri: priKey)
                        
                        DB.shared.addOrUpdateObjects([account] as [EHAccount])
                        
                        return AccountManager.shared.loadAccount(account: account)
                            .flatMap({ (_) -> Observable<EHAccount> in
                                return Observable.just(account)
                            })
                    })
                    .subscribe(onNext: { [weak self] (account) in
                        
                        AccountManager.shared.refreshUI()
                        
                        guard let nc = self?.navigationController else { return }
                        
                        self?.flowDelegate?.returnToMain(from: nc)
                        
                        }, onError: { [weak self] (error) in
                            print(error)
                            Popup.present(style: Popup.Style.failed, description: "\(error)")
                            self?.view.endEditing(true)
                    })
                    .disposed(by: bag)
            } else {
                
                let lockedAccount = EHAccount(account: "", publicKey: pubKey, owner: true)
                
                _ = Security.shared.setEncryptedKey(pub: pubKey, pri: priKey)
                
                 DB.shared.addOrUpdateObjects([lockedAccount] as [EHAccount])
                
                AccountManager.shared.refreshUI()
                
                guard let nc =  navigationController else { return }
                
                flowDelegate?.returnToMain(from: nc)
            }
            
            
            
            
        }
        
        
        
    }
    
    fileprivate func isNetworkAvailable() -> Bool {
        //TODO: Implement, 네트워크가 비활성화시 일단 private 키를 저장하고, 월렛 로딩할때 명시적으로 account 를 Get 하는 옵션을 준다.
        return true
    }
    
    
}







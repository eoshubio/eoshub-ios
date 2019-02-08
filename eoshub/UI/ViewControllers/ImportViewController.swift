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
    @IBOutlet fileprivate weak var lbWarning: UITextView!
    @IBOutlet fileprivate weak var btnImport: UIButton!
//    @IBOutlet fileprivate weak var btnFindAccount: UIButton!
    
    deinit {
        Log.d("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        EHAnalytics.trackEvent(event: .try_import_account)
        lbTitle.text = LocalizedString.Wallet.Import.title
        btnImport.setTitle(LocalizedString.Wallet.Import.store, for: .normal)
        lbWarningTitle.text = LocalizedString.Create.Import.warningTitle
        
        let warningText = LocalizedString.Create.Import.warning + "\n" + LocalizedString.Create.Import.setting
        let warning = NSMutableAttributedString(string: warningText)
        
        let keyChainDoc = URLs.iCloudKeychain
        warning.addAttributeFont(text: warning.string, font: Font.appleSDGothicNeo(.regular).uiFont(14))
        if let url = URL(string: keyChainDoc) {
            warning.addAttributeURL(text: LocalizedString.Create.Import.keychain, url: url)
            warning.addAttributeFont(text: LocalizedString.Create.Import.keychain, font: Font.appleSDGothicNeo(.semiBold).uiFont(14))
        }
   
        warning.addAttributeFont(text: LocalizedString.Create.Import.setting, font: Font.appleSDGothicNeo(.semiBold).uiFont(14))
        
        warning.addLineHeight(height: 4)
        
        lbWarning.attributedText = warning
        
//        let txt = LocalizedString.Wallet.Import.findAccount
//        let txtFindAccount = NSMutableAttributedString(string: txt,
//        attributes: [NSAttributedStringKey.font: Font.appleSDGothicNeo(.regular).uiFont(12),
//                     NSAttributedStringKey.foregroundColor: Color.darkGray.uiColor])
//
//        if let clickRange = txt.range(of: LocalizedString.Wallet.Import.clickHere) {
//            let clickNSRange = txt.nsRange(from: clickRange)
//            txtFindAccount.addAttributes([NSAttributedStringKey.font : Font.appleSDGothicNeo(.bold).uiFont(12),
//                                          NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue],
//                                         range: clickNSRange)
//        }
        
        
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
        
        txtPriKey.resignFirstResponder()
        
        //1. get public key from private key
        guard let priKey = txtPriKey.text else { return }
        
        guard let pubKey = EOS_Key_Encode.eos_publicKey_(with_wif: priKey) else { return }
        
        if let existAccount = AccountManager.shared.getAccount(pubKey: pubKey), existAccount.owner {
            Popup.present(style: Popup.Style.failed, description: "\(EOSErrorType.existAccount)")
        } else {
            if Reachability.isConnectedToNetwork() {
                WaitingView.shared.start()
                RxEOSAPI.getAccountFromPubKey(pubKey: pubKey)
                    .flatMap({ (accountName) -> Observable<EHAccount> in
                        let account = EHAccount(userId: UserManager.shared.userId, account: accountName, publicKey: pubKey, owner: true)
                        
                        //2. save account with public Key
                        _ = Security.shared.setEncryptedKey(pub: pubKey, pri: priKey)
                        
                        DB.shared.addOrUpdateObjects([account] as [EHAccount])
                        
                        return AccountManager.shared.loadAccount(account: account)
                            .flatMap({ (_) -> Observable<EHAccount> in
                                return Observable.just(account)
                            })
                    })
                    .subscribe(onNext: { [weak self] (account) in
                        
                        EHAnalytics.trackEvent(event: .import_account)
                        
                        AccountManager.shared.refreshUI()
                        
                        Popup.present(style: .success, description: LocalizedString.Create.Import.imported)
                        
                        self?.navigationController?.popViewController(animated: true)
                        
                        }, onError: { [weak self] (error) in
                            if let error = error as? PrettyPrintedPopup {
                                error.showPopup()
                            } else {
                                Popup.present(style: .failed, description: "\(error)")
                            }
                            self?.view.endEditing(true)
                    }) {
                        WaitingView.shared.stop()
                    }
                    .disposed(by: bag)
            } else {
                
                let lockedAccount = EHAccount(userId: UserManager.shared.userId, publicKey: pubKey, owner: true)
                
                _ = Security.shared.setEncryptedKey(pub: pubKey, pri: priKey)
                
                 DB.shared.addOrUpdateObjects([lockedAccount] as [EHAccount])
                
                AccountManager.shared.refreshUI()
                
                Popup.present(style: .success, description: LocalizedString.Create.Import.imported)
                
                navigationController?.popViewController(animated: true)
            }
            
            
            
            
        }
        
        
        
    }
    
}







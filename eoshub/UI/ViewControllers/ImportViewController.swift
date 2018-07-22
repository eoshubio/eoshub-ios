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
    @IBOutlet fileprivate weak var btnPaste: UIButton!
    @IBOutlet fileprivate weak var btnImport: UIButton!
    @IBOutlet fileprivate weak var btnFindAccount: UIButton!
    
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
        btnPaste.setTitle(LocalizedString.Common.paste, for: .normal)
        btnImport.setTitle(LocalizedString.Wallet.Import.store, for: .normal)
        
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
        
        
        btnFindAccount.setAttributedTitle(txtFindAccount, for: .normal)
        
        txtPriKey.placeholder = LocalizedString.Wallet.priKey
        txtPriKey.delegate = self
        
        txtPriKey.padding.right = btnPaste.bounds.width + 5
        
        
        
    }
    
    private func bindActions() {
        
        
        
        btnFindAccount.rx.singleTap
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goFindAccount(from: nc)
            }
        .disposed(by: bag)
        
        btnImport.rx.singleTap
            .bind { [weak self] in
                self?.handleImportKey()
            }
            .disposed(by: bag)
        
        btnPaste.rx.singleTap
            .flatMap({ [weak self] (_) -> Observable<Bool> in
                guard let pasted = UIPasteboard.general.string else { return Observable.just(false) }
                self?.txtPriKey.text = pasted
                return Observable.just(EOS_Key_Encode.validateWif(pasted))
            })
            .bind(to: btnImport.rx.isEnabled)
            .disposed(by: bag)
        
        txtPriKey.rx.text.orEmpty
            .flatMap { (priKey) -> Observable<Bool> in
                return Observable.just(EOS_Key_Encode.validateWif(priKey))
            }
            .bind(to: btnImport.rx.isEnabled)
            .disposed(by: bag)
        
    }
    
    fileprivate func handleImportKey() {
        
        //1. get public key from private key
        guard let priKey = txtPriKey.text else { return }
        
        if EOS_Key_Encode.validateWif(priKey) == false {
            //TODO: Error popup
        }
        
        guard let pubKey = EOS_Key_Encode.eos_publicKey_(with_wif: priKey) else { return }
        
        //TODO: Check network is available
        if true {
            RxEOSAPI.getAccountFromPubKey(pubKey: pubKey)
                .flatMap({ (accountName) -> Observable<EHAccount> in
                    var account: EHAccount
                    
                    if let existAccount = AccountManager.shared.getAccount(accountName: accountName) {
                        if existAccount.owner {
                            return Observable.error(EOSErrorType.existAccount)
                        } else {
                            account = existAccount
                        }
                    } else {
                        account = EHAccount(account: accountName, publicKey: pubKey, owner: true)
                    }
                    
                    //2. save account with public Key
                    _ = Security.shared.setEncryptedKey(pub: pubKey, pri: priKey)
                    
                    return AccountManager.shared.loadAccount(account: account)
                            .flatMap({ (_) -> Observable<EHAccount> in
                                return Observable.just(account)
                            })
                 })
                .subscribe(onNext: { [weak self] (account) in
                    
                    DB.shared.addOrUpdateObjects([account] as [EHAccount])
                    
                    guard let nc = self?.navigationController else { return }
                    
                    self?.flowDelegate?.returnToMain(from: nc)
                    
                    }, onError: { [weak self] (error) in
                        print(error)
                        Popup.present(style: Popup.Style.failed, description: "\(error)")
                        self?.view.endEditing(true)
                })
                .disposed(by: bag)
        }
        
    }
    
    fileprivate func isNetworkAvailable() -> Bool {
        //TODO: Implement, 네트워크가 비활성화시 일단 private 키를 저장하고, 월렛 로딩할때 명시적으로 account 를 Get 하는 옵션을 준다.
        return true
    }
    
    
}







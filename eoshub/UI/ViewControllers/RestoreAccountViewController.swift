//
//  RestoreAccountViewController.swift
//  eoshub
//
//  Created by kein on 2018. 9. 16..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class RestoreAccountViewController: PreferAccountViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        
        EHAnalytics.trackEvent(event: .try_restore_account)
        
        lbTitle.text = LocalizedString.Create.Restore.title
        btnPaste.setTitle(LocalizedString.Common.paste, for: .normal)
        
        txtAccount.placeholder = LocalizedString.Create.Account.name
        txtAccount.delegate = self
        
        txtAccount.padding.right = btnPaste.bounds.width + 5
        
        btnAdd.setTitle(LocalizedString.Create.Restore.action, for: .normal)
    }
    
    private func bindActions() {
        
        
        btnPaste.rx.singleTap
            .bind { [weak self] in
                guard let pasted = UIPasteboard.general.string else { return }
                self?.txtAccount.text = pasted
            }
            .disposed(by: bag)
        
        btnAdd.rx.singleTap
            .bind { [weak self] in
                self?.handleAddAccount()
            }
            .disposed(by: bag)
        
        txtAccount.rx.text.orEmpty
            .flatMap { (accountName) -> Observable<Bool> in
                return Observable.just(Validator.accountName(name: accountName))
            }
            .bind(to: btnAdd.rx.isEnabled)
            .disposed(by: bag)
        
    }
    
    
    private func handleAddAccount() {
        
        txtAccount.resignFirstResponder()
        
        guard let accountName = txtAccount.text else { return }
        WaitingView.shared.start()
        RxEOSAPI.getPubKeyFromAccount(account: accountName)
            .flatMap({ (pubKey) -> Observable<EHAccount> in
                let account = EHAccount(userId: UserManager.shared.userId, account: accountName, publicKey: pubKey, owner: false)
                
                DB.shared.addOrUpdateObjects([account] as [EHAccount])
                
                EHAnalytics.trackEvent(event: .restore_account)
                
                return AccountManager.shared.loadAccount(account: account)
                    .flatMap({ (_) -> Observable<EHAccount> in
                        return Observable.just(account)
                    })
            })
            .subscribe(onError: { (error) in
                if let error = error as? PrettyPrintedPopup {
                    error.showPopup()
                } else {
                    Popup.present(style: .failed, description: "\(error)")
                }
            }, onCompleted: { [weak self] in
                guard let nc = self?.navigationController else { return }
                
                self?.flowDelegate?.returnToMain(from: nc)
            }) {
                WaitingView.shared.stop()
            }
            .disposed(by: bag)
        
        
    }
    
    
    
}

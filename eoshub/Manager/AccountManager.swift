//
//  AccountManager.swift
//  eoshub
//
//  Created by kein on 2018. 7. 11..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

class AccountManager {
    static let shared = AccountManager()
      
    let pinValidated = PublishSubject<Void>()
    
    var needPinConfirm: Bool = true
    
    lazy var eoshubAccounts: Results<EHAccount> = {
        return DB.shared.getAccounts().sorted(byKeyPath: "created", ascending: true)
    }()
    
    var mainAccount: AccountInfo? = nil // save to preference
    
    var infos: [AccountInfo] = []
    
    let accountInfoRefreshed = PublishSubject<Void>()
    
    func refreshUI() {
        accountInfoRefreshed.onNext(())
    }
    
    func loadAccounts() -> Observable<Void> {
        infos.removeAll()
        return Observable.from(Array(eoshubAccounts))
            .concatMap { [unowned self](account) -> Observable<Void> in
                return self.getAccountInfo(account: account)
                    .do(onCompleted: { [weak self] in
                        
                        //Refresh main account
                        self?.infos.forEach({ (info) in
                            if info.account == self?.mainAccount?.account {
                                self?.mainAccount = info
                            }
                        })
                        
                        self?.refreshUI()
                    })
        }
    }
    
    private func getAccountInfo(account: EHAccount) -> Observable<Void> {
        
        let knownTokens = TokenManager.shared.knownTokens
        
        return RxEOSAPI.getAccount(name: account.account)
            .flatMap({ [weak self](account) ->  Observable<AccountInfo> in
                let owner = self?.eoshubAccounts.filter("account = '\(account.name)'").first?.owner ?? false
                let info = AccountInfo(with: account, isOwner: owner)
                self?.infos.append(info)
                return Observable.just(info)
            })
            .flatMap { (info) -> Observable<Void> in
                return RxEOSAPI.getTokens(account: account, tokenInfos: knownTokens)
                    .flatMap({ (tokenBalances) -> Observable<Void> in
                        info.addTokens(currency: tokenBalances)
                        return Observable.just(())
                    })
            }
    }
    
}

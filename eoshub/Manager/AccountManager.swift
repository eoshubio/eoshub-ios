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
    
    lazy var eoshubAccounts: Results<EHAccount> = {
        return DB.shared.getAccounts().sorted(byKeyPath: "created", ascending: true)
    }()
    
    var mainAccount: AccountInfo? = nil // save to preference
    
    lazy var infos: Results<AccountInfo> = {
       return DB.shared.getAccountInfos()
    }()
    
    let accountInfoRefreshed = PublishSubject<Void>()
    
    func refreshUI() {
        accountInfoRefreshed.onNext(())
    }
    
    func loadAccounts() -> Observable<Void> {
        
        var accountInfos: [AccountInfo] = []
        
        return Observable.from(Array(eoshubAccounts))
            .concatMap { [unowned self](account) -> Observable<AccountInfo> in
                return self.getAccountInfo(account: account)
            }
            .do(onNext: { (info) in
                accountInfos.append(info)
            }, onError: { (error) in
                Log.e(error)
            }, onCompleted: {
                DB.shared.addOrUpdateObjects(accountInfos)
                self.refreshUI()
            })
            .flatMap({ _ in Observable.just(())})
    }
    
    private func getAccountInfo(account: EHAccount) -> Observable<AccountInfo> {
        
        let knownTokens = TokenManager.shared.knownTokens
        
        return RxEOSAPI.getAccount(name: account.account)
            .flatMap({ [weak self](account) ->  Observable<AccountInfo> in
                let owner = self?.eoshubAccounts.filter("account = '\(account.name)'").first?.owner ?? false
                let info = AccountInfo(with: account, isOwner: owner)
                return Observable.just(info)
            })
            .flatMap { (info) -> Observable<AccountInfo> in
                return RxEOSAPI.getTokens(account: account, tokenInfos: knownTokens)
                        .flatMap({ (tokenBalances) -> Observable<AccountInfo> in
                            info.addTokens(currency: tokenBalances)
                            return Observable.just(info)
                        })
            }
    }
    
}

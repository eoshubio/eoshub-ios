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
    
    private let bag = DisposeBag()
    
    var eoshubAccounts: Results<EHAccount> {
        return DB.shared.getAccounts(userId: UserManager.shared.userId).sorted(byKeyPath: "created", ascending: true)
    }
    
    var mainAccount: AccountInfo? = nil // save to preference
    
    var infos: Results<AccountInfo> {
       return DB.shared.getAccountInfos()
    }
    
    var ownerInfos: Results<AccountInfo> {
        return DB.shared.getAccountInfos().filter("ownerMode = true")
    }
    
    
    let accountInfoRefreshed = PublishSubject<Void>()
    
    func refreshUI() {
        accountInfoRefreshed.onNext(())
        EHAnalytics.setUserProperties()
    }
    
    func loadAccounts() -> Observable<Void> {
        
        var accountInfos: [AccountInfo] = []
        let accounts = eoshubAccounts.filter("account != ''")
        return Observable.from(Array(accounts))
            .concatMap { [unowned self](account) -> Observable<AccountInfo> in
                return self.getAccountInfo(account: account)
            }
            .do(onNext: { (info) in
                 accountInfos.append(info)
            }, onError: { (error) in
                Log.e(error)
            }, onCompleted: {
                DB.shared.syncObjects(accountInfos)
            }, onDispose: { [weak self] in
                self?.refreshUI()
            })
            .flatMap({ _ in Observable.just(())})
    }
    
    func doLoadAccount() {
        loadAccounts()
            .subscribe(onDisposed: {
                Log.d("disposed")
             
            })
            .disposed(by: bag)
    }
    
    func refreshAccount(account: String) -> Observable<Void> {
        guard let ehaccount = getAccount(accountName: account) else { return Observable.error(EOSHubError.txNotFound)}
        return getAccountInfo(account: ehaccount, isFirstTime: false)
            .do(onNext: { (info) in
                DB.shared.addOrUpdateObjects([info] as [AccountInfo])
            }, onError: { (error) in
                Log.e(error)
            }, onDispose: {
                self.refreshUI()
            })
            .flatMap({ _ in Observable.just(())})
    }
    
    func loadAccount(account: EHAccount) -> Observable<Void> {
        return getAccountInfo(account: account, isFirstTime: true)
                .do(onNext: { (info) in
                    DB.shared.addOrUpdateObjects([info] as [AccountInfo])
                }, onError: { (error) in
                    Log.e(error)
                }, onDispose: {
                    self.refreshUI()
                })
                .flatMap({ _ in Observable.just(())})
    }
    
    func getAccount(accountName: String) -> EHAccount? {
        if let found = eoshubAccounts.filter("account = '\(accountName)'").first {
            return found
        } else {
            return nil
        }
    }
    
    func getAccount(pubKey: String) -> EHAccount? {
        if let found = eoshubAccounts.filter("publicKey = '\(pubKey)'").first {
            return found
        } else {
            return nil
        }
    }
    
    private func getAccountInfo(account ehAccount: EHAccount, isFirstTime: Bool = false) -> Observable<AccountInfo> {
        
        let preferTokens = isFirstTime ? TokenManager.shared.knownTokens.map({ $0.token }) : ehAccount.tokens
        
        return RxEOSAPI.getAccount(name: ehAccount.account)
            .flatMap({ (account) ->  Observable<AccountInfo> in
                let info = AccountInfo(with: account, storedKey: ehAccount.publicKey)
                return Observable.just(info)
            })
            .flatMap({ (info) -> Observable<AccountInfo> in
                //Refund unstaked EOS if needed
                if info.ownerMode && info.hasRefundedEOS {
                    let wallet = Wallet(account: ehAccount)
                    return RxEOSAPI.refund(owner: info.account, wallet: wallet,
                                           authorization: Authorization(actor: info.account, permission: info.permission)).catchErrorJustReturn([:])
                                    .flatMap({ (json) -> Observable<AccountInfo> in
                                        Log.i(json)
                                        return Observable.just(info)
                                    })
                } else {
                    return Observable.just(info)
                }
            })
            .flatMap { (info) -> Observable<AccountInfo> in
                return RxEOSAPI.getTokens(account: ehAccount, tokens: preferTokens)
                        .flatMap({ (tokenBalances) -> Observable<AccountInfo> in
                            
                            if isFirstTime {
                                let havingToken = tokenBalances.filter { $0.quantity > 0 }
                                info.addTokens(currency: havingToken)
                                let tokens = havingToken.map { $0.token }
                                DB.shared.safeWrite {
                                    ehAccount.setPreferTokens(tokens: tokens)
                                }
                            } else {
                                info.addTokens(currency: tokenBalances)
                            }
                            
                            return Observable.just(info)
                        })
                        .takeLast(1)
            }
    }
    
    
    func queryAccountInfo(by accountName: String) -> AccountInfo? {
        return infos.first(where: { $0.account == accountName })
    }
}

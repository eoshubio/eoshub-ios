//
//  AccountManager.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 24..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import RxSwift

internal class AccountManager {
    static let shared = AccountManager()
    
    internal let accountInfo = BehaviorSubject<Account?>(value: nil)
    
    private let bag = DisposeBag()
    
    init() {
        
    }
    
    
    func refreshAccountInfo() {
        let testname = WalletManager.shared.getWallet()?.name ?? ""
        RxEOSAPI.getAccount(name: testname)
            .subscribe(onNext: { (json) in
                let account = Account(json: json)
                self.accountInfo.onNext(account)
                print(json)
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: bag)
    }
}

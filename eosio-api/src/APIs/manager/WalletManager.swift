//
//  WalletManager.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import RxSwift
import Realm
import RealmSwift

class WalletManager {
    static let shared = WalletManager()
    
    private var wallets: [Wallet] = []
    
    private var keys: [Key] = []
    
    fileprivate let db = DB.shared
    
    var balance = BehaviorSubject<[Currency]>(value: [])
    
    private let bag = DisposeBag()
    
    init() {
        loadWallets()
        loadKeys()
        refreshBalance()
    }
    
    private func loadWallets() {
        wallets = Array(db.realm.objects(Wallet.self))
    }
    
    private func loadKeys() {
        keys = Array(db.realm.objects(Key.self))
    }
    
    func addWallet(wallet: Wallet) {
        db.safeWrite {
            db.realm.add(wallet)
            db.realm.add(Key(value: wallet.publicKey))
        }
        loadWallets()
        loadKeys()
    }
    
    func getWallet() -> Wallet? {
        return wallets.first
    }
    
    func getKeys() -> [String] {
        return Array(keys).map{ $0.id }
    }
    
    func refreshBalance() {
        guard let wallet = wallets.first else { return }
        RxEOSAPI.getCurrencyBalance(name: wallet.name, symbol: "EOS")
                .bind(onNext: { (currency) in
                    self.balance.onNext(currency)
                })
                .disposed(by: bag)
    }
    
}

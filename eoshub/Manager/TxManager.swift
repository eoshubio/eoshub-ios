//
//  TxManager.swift
//  eoshub
//
//  Created by kein on 2018. 7. 16..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

class TxManager {
    static let shared = TxManager()
    
    var refreshUI = PublishSubject<Void>()
    
    lazy var transactions: Results<Tx> = {
        return DB.shared.getTxs()
    }()
    
    func loadTx(for account: String) -> Observable<Void> {
        return RxEOSAPI.getTxHistory(account: account)
                .flatMap { (txs) -> Observable<Void> in
                    DB.shared.addOrUpdateObjects(txs)
                    self.refreshUI.onNext(())
                    return Observable.just(())
                }
    }
    
    func getTx(for account: String) -> Results<Tx> {
        return transactions.filter("data CONTAINS '\(account)'").sorted(byKeyPath: "timeStamp", ascending: false)
    }
    
}

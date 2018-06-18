//
//  WalletView.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class WalletView: UIView {
    
    @IBOutlet fileprivate weak var accountName: UILabel?
    @IBOutlet fileprivate weak var btnKey: UIButton?
    @IBOutlet fileprivate weak var balance: UILabel?
    @IBOutlet fileprivate weak var btnSend: UIButton?
    @IBOutlet fileprivate weak var btnReceive: UIButton?
    
    
    var wallet: Wallet?
    
    let bag = DisposeBag()
    
    func configure(wallet: Wallet) {
        accountName?.text = wallet.name
        btnKey?.setTitle(wallet.publicKey, for: .normal)
        balance?.text = "Loading..."
        
//        wallet.balance
//            .subscribe(onNext: { (currency) in
//
//            }, onError: { (error) in
//
//            })
        
        
    }
}

//
//  CreateWalletViewController.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class CreateWalletViewController: UIViewController {
    
    @IBOutlet fileprivate weak var txtAccountName: UITextField?
    @IBOutlet fileprivate weak var btnCreate: UIButton?
    var flowEventDelgate: CreateWalletFlowEventDelegate?
    
    private let bag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        
    }
    
    private func bindActions() {
        btnCreate?.rx.singleTap
            .bind { [weak self](_) in
                guard let name = self?.txtAccountName?.text else { return }
                self?.createWallet(name: name)
            }
            .disposed(by: bag)
        
    }
    
    fileprivate func validateName(walletName: String) -> Bool {
        return true
    }
    
    fileprivate func createWallet(name: String) {
        
        if validateName(walletName: name) == false {
            print("name validation failure")
            return
        }
        
        RxEOSAPI.createAccount(name: name, authorization: Authorization.eosio)
            .subscribe(onNext: { [weak self](json) in
                print(json)
                self?.goToWalletView()
            })
            .disposed(by: bag)
    }
    
    fileprivate func goToWalletView() {
        guard let nc = navigationController else { return }
        flowEventDelgate?.goToWallet(nc: nc)
    }
}


extension CreateWalletViewController {
    override var prefersStatusBarHidden: Bool {
        return false
    }
}

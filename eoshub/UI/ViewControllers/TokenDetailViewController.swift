//
//  TokenDetailViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 15..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class TokenDetailViewController: BaseViewController {
    
    var flowDelegate: TokenDetailFlowEventDelegate?
    
    @IBOutlet fileprivate weak var account: UILabel!
    @IBOutlet fileprivate weak var lbAvailable: UILabel!
    @IBOutlet fileprivate weak var lbBalance: UILabel!
    @IBOutlet fileprivate weak var lbSymbol: UILabel!
    @IBOutlet fileprivate weak var btnSend: UIButton!
    @IBOutlet fileprivate weak var btnReceive: UIButton!
    @IBOutlet fileprivate weak var tokenInfoView: UITableView!
    
    fileprivate var tokenInfo: TokenBalanceInfo!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .white)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        let accountInfo = tokenInfo.owner
        
        let balance = tokenInfo.currency
        
        title = balance.symbol
        
        account.text = accountInfo.account
        
        lbAvailable.text = LocalizedString.Wallet.Transfer.available + balance.symbol
        
        lbBalance.text = balance.balance
        
        lbSymbol.text = balance.symbol
        
        btnSend.setTitle(LocalizedString.Wallet.send, for: .normal)
        
        btnReceive.setTitle(LocalizedString.Wallet.receive, for: .normal)
    }
    
    private func bindActions() {
        btnSend.rx.singleTap
            .bind { [weak self] in
               self?.goToSend()
            }
            .disposed(by: bag)
        
        btnReceive.rx.singleTap
            .bind { [weak self] in
                self?.goToReceive()
            }
            .disposed(by: bag)
    }
    
    func configure(tokenInfo: TokenBalanceInfo) {
        self.tokenInfo = tokenInfo
    }
    
    fileprivate func goToSend() {
        guard let nc = navigationController else { return }
        flowDelegate?.goToSend(from: nc, with: tokenInfo)
    }
    
    fileprivate func goToReceive() {
        guard let nc = navigationController else { return }
        flowDelegate?.goToReceive(from: nc, with: tokenInfo)
    }
}

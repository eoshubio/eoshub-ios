//
//  AccountDetailFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 20..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class AccountDetailFlowController: FlowController, AccountDetailFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .accountDetail }
    
    var account: AccountInfo!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: AccountInfo) {
        self.account = account
    }
    
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: AccountDetailViewController.self)
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "AccountDetailViewController") as? AccountDetailViewController else { return }
        vc.flowDelegate = self
        vc.configure(account: account)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    
    //MARK: AccountDetailFlowEventDelegate
    func goToResources(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = WalletDetailFlowController(configure: config)
        fc.configure(account: account)
        fc.start(animated: true)
    }
    
    func goToVote(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = VoteFlowController(configure: config)
        fc.configure(account: account)
        fc.start(animated: true)
    }
    
    func goToKeyPair(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = KeypairFlowController(configure: config)
        fc.configure(account: account)
        fc.start(animated: true)
    }
    
    func goToTx(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = TxFlowController(configure: config)
        fc.configure(accountName: account.account, actions: nil, filter: nil)
        fc.start(animated: true)
    }
    
    func goToToken(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = TokenAddFlowController(configure: config)
        fc.configure(account: account)
        fc.start(animated: true)
    }
    
    func goToDonate(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = DonateFlowController(configure: config)
        fc.configure(account: account)
        fc.start(animated: true)
    }
}


protocol AccountDetailFlowEventDelegate: FlowEventDelegate {
    func goToResources(from nc: UINavigationController)
    func goToVote(from nc: UINavigationController)
    func goToKeyPair(from nc: UINavigationController)
    func goToTx(from nc: UINavigationController)
    func goToToken(from nc: UINavigationController)
    func goToDonate(from nc: UINavigationController)
}

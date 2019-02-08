//
//  DelegateFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 15..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


class DelegateFlowController: FlowController, DelegateFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .delegatebw }
    
    var account: AccountInfo!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: AccountInfo) {
        self.account = account
    }
    
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: DelegateViewController.self)
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "DelegateViewController") as? DelegateViewController else { return }
        vc.flowDelegate = self
        vc.configure(account: account)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    func goToTx(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = TxFlowController(configure: config)
        
        fc.configure(accountName: account.account, actions: [Contract.Action.delegatebw, Contract.Action.undelegatebw], filter: nil)
        
        fc.start(animated: true)
    }
 
}

protocol DelegateFlowEventDelegate: FlowEventDelegate {
    func goToTx(from nc: UINavigationController)
}


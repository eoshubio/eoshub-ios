//
//  SellRamFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 16..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


class SellRamFlowController: FlowController, SellRamFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .sellram }
    
    var account: AccountInfo!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: AccountInfo) {
        self.account = account
    }
    
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: SellRamViewController.self)
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "SellRamViewController") as? SellRamViewController else { return }
        vc.flowDelegate = self
        vc.configure(account: account)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    func goToTx(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = TxFlowController(configure: config)
        
        fc.configure(accountName: account.account, actions: [Contract.Action.buyram, Contract.Action.sellram], filter: nil)
        
        fc.start(animated: true)
    }
}

protocol SellRamFlowEventDelegate: FlowEventDelegate {
    func goToTx(from nc: UINavigationController)
}


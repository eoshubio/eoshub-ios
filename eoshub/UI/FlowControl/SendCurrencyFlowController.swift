//
//  SendCurrencyFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 12..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class SendCurrencyFlowController: FlowController, SendFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .send }
    
    var account: AccountInfo!
    var balance: Currency!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: AccountInfo, balance: Currency) {
        self.account = account
        self.balance = balance
    }
    
    
    func show(animated: Bool) {
        
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "SendCurrencyViewController") as? SendCurrencyViewController else { return }
        vc.flowDelegate = self
        vc.configure(account: account, balance: balance)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    func goToTx(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = TxFlowController(configure: config)
        fc.start(animated: true)
    }
    
}


protocol SendFlowEventDelegate: FlowEventDelegate {
    func goToTx(from nc: UINavigationController)
}

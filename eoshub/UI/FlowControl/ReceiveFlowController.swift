//
//  ReceiveFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 13..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class ReceiveFlowController: FlowController, ReceiveEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .receive }
    
    var account: AccountInfo!
    var symbol: Symbol!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: AccountInfo, symbol: Symbol) {
        self.account = account
        self.symbol = symbol
    }
    
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: ReceiveViewController.self)
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "ReceiveViewController") as? ReceiveViewController else { return }
        vc.flowDelegate = self
        vc.configure(account: account)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    func goToTx(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = TxFlowController(configure: config)
        fc.configure(accountName: account.account, actions: [.transfer], filter: symbol)
        fc.start(animated: true)
    }
    
}

protocol ReceiveEventDelegate: FlowEventDelegate {
    func goToTx(from nc: UINavigationController)
}



//
//  UndelegateFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 15..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


class UndelegateFlowController: FlowController, UndelegateFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .undelegatebw }
    
    var account: AccountInfo!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: AccountInfo) {
        self.account = account
    }
    
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: UndelegateViewController.self)
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "UndelegateViewController") as? UndelegateViewController else { return }
        vc.flowDelegate = self
        vc.configure(account: account)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    func goToTx(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = TxFlowController(configure: config)
        
        fc.configure(accountName: account.account, actions: [.delegatebw, .undelegatebw], filter: nil)
        
        fc.start(animated: true)
    }
    
}

protocol UndelegateFlowEventDelegate: FlowEventDelegate {
    func goToTx(from nc: UINavigationController)
}

//
//  WalletDetailFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 12..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class WalletDetailFlowController: FlowController, WalletDetailFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .resouces }
    
    var account: AccountInfo!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: AccountInfo) {
        self.account = account
    }
    
    
    func show(animated: Bool) {
       EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: WalletDetailViewController.self)
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "WalletDetailViewController") as? WalletDetailViewController else { return }
        vc.flowDelegate = self
        vc.configure(viewModel: account)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    
    //MARK: WalletDetailFlowEventDelegate
    func goToDelegateBW(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = DelegateFlowController(configure: config)
        fc.configure(account: account)
        fc.start(animated: true)
    }
    
    func goToUndelegateBW(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = UndelegateFlowController(configure: config)
        fc.configure(account: account)
        fc.start(animated: true)
    }
    
    func goToBuyRam(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = BuyRamFlowController(configure: config)
        fc.configure(account: account)
        fc.start(animated: true)
    }
    
    func goToSellRam(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = SellRamFlowController(configure: config)
        fc.configure(account: account)
        fc.start(animated: true)
    }
}

protocol WalletDetailFlowEventDelegate: FlowEventDelegate {
    func goToDelegateBW(from nc: UINavigationController)
    func goToUndelegateBW(from nc: UINavigationController)
    func goToBuyRam(from nc: UINavigationController)
    func goToSellRam(from nc: UINavigationController)
}


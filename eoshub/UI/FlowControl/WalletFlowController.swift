//
//  WalletFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit



class WalletFlowController: FlowController, WalletFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .wallet }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        var vc: WalletViewController?
        if case FlowType.tab = configure.flowType {
            vc = (configure.container as? TabBarViewController)?.viewControllers.filter({ $0 is WalletViewController }).first as? WalletViewController
        } else {
            vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalletViewController") as? WalletViewController
        }
        
        vc?.flowDelegate = self
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    
    //MARK: WalletFlowEventDelegate
    func goToSetting(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = SettingFlowController(configure: config)
        fc.start(animated: true)
    }
    
    func goToWalletDetail(from nc: UINavigationController, with account: AccountInfo) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = WalletDetailFlowController(configure: config)
        fc.configure(account: account)
        fc.start(animated: true)
    }
    
    func goToCreate(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .modal)
        let fc = CreateFlowController(configure: config)
        fc.configure(items: [.create, .privateKey, .publicKey])
        fc.start(animated: true)
    }
    
    func goToSend(from nc: UINavigationController, with account: AccountInfo) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = SendCurrencyFlowController(configure: config)
        let balance = Currency(balance: account.availableEOS, symbol: "EOS")
        fc.configure(account: account, balance: balance)
        fc.start(animated: true)
    }
    
    func goToReceive(from nc: UINavigationController, with account: AccountInfo) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = ReceiveFlowController(configure: config)
        fc.configure(account: account, symbol: .eos)
        fc.start(animated: true)
    }
    
    func goToTokenDetail(from nc: UINavigationController, with tokenBalance: TokenBalanceInfo) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = TokenDetailFlowController(configure: config)
        fc.configure(tokenBalance: tokenBalance)
        fc.start(animated: true)
    }
}

protocol WalletFlowEventDelegate: FlowEventDelegate {
    
    func goToSetting(from nc: UINavigationController)
    func goToWalletDetail(from nc: UINavigationController, with account: AccountInfo)
    func goToSend(from nc: UINavigationController, with account: AccountInfo)
    func goToReceive(from nc: UINavigationController, with account: AccountInfo)
    func goToCreate(from nc: UINavigationController)
    func goToTokenDetail(from nc: UINavigationController, with tokenBalance: TokenBalanceInfo)
}

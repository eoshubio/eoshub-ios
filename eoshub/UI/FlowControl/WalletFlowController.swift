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
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: WalletViewController.self)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
        
        vc.show()
        vc.flowDelegate = self
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
        let fc = AccountDetailFlowController(configure: config)
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
        let balance = Currency(balance: account.availableEOS, token: .eos)
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
    
    func goToAddToken(from nc: UINavigationController, with account: EHAccount) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = TokenAddFlowController(configure: config)
        fc.configure(account: account)
        fc.start(animated: true)
    }
    
    func cratePin(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .modal)
        let fc = CreatePinFlowController(configure: config)
        fc.start(animated: true)
    }
    
    func validatePin(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .modal)
        let fc = ValidatePinFlowController(configure: config)
        fc.start(animated: true)
    }
    
    func goToDonate(from nc: UINavigationController, with account: AccountInfo?) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = DonateFlowController(configure: config)
        fc.configure(account: account)
        fc.start(animated: true)
    }
    
    func goToForgotPW(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = ForgetPWFlowController(configure: config)
        fc.configure(email: UserManager.shared.email)
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
    func goToAddToken(from nc: UINavigationController, with account: EHAccount)
    func goToDonate(from nc: UINavigationController, with account: AccountInfo?)
    func cratePin(from nc: UINavigationController)
    func validatePin(from nc: UINavigationController)
    func goToForgotPW(from nc: UINavigationController)
}

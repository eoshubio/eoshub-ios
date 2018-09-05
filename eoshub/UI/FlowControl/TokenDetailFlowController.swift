//
//  TokenDetailFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 15..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class TokenDetailFlowController: FlowController, TokenDetailFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .wallet }
    
    var tokenBalance: TokenBalanceInfo!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(tokenBalance: TokenBalanceInfo) {
        self.tokenBalance = tokenBalance
    }
    
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: TokenDetailViewController.self)
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "TokenDetailViewController") as? TokenDetailViewController else { return }
        vc.flowDelegate = self
        vc.configure(tokenInfo: tokenBalance)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    
    //MARK: TokenDetailFlowEventDelegate
    func goToSend(from nc: UINavigationController, with tokenInfo: TokenBalanceInfo) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = SendCurrencyFlowController(configure: config)
        fc.configure(account: tokenInfo.owner, balance: tokenInfo.currency)
        fc.start(animated: true)
    }
    
    func goToReceive(from nc: UINavigationController, with tokenInfo: TokenBalanceInfo) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = ReceiveFlowController(configure: config)
        fc.configure(account: tokenInfo.owner, symbol: tokenBalance.currency.symbol)
        fc.start(animated: true)
    }
    
}

protocol TokenDetailFlowEventDelegate: FlowEventDelegate {
    func goToSend(from nc: UINavigationController, with tokenInfo: TokenBalanceInfo)
    func goToReceive(from nc: UINavigationController, with tokenInfo: TokenBalanceInfo)
}

//
//  SendCurrencyFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 12..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class SendCurrencyFlowController: FlowController, SendFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .send }
    
    var account: AccountInfo!
    var balance: Currency!
    var to: String?
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: AccountInfo, balance: Currency, to: String? = nil) {
        self.account = account
        self.balance = balance
        self.to = to
    }
    
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: SendCurrencyViewController.self)
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "SendCurrencyViewController") as? SendCurrencyViewController else { return }
        vc.flowDelegate = self
        vc.configure(account: account, balance: balance, to: to)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    func goToTx(from nc: UINavigationController, account: AccountInfo, filter: Symbol?) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = TxFlowController(configure: config)
        fc.configure(accountName: account.account, actions: [Contract.Action.transfer], filter: filter)
        fc.start(animated: true)
    }
    
    
    func goToQRScanner(from nc: UINavigationController)  -> Observable<String?> {
        let config = FlowConfigure(container: nc, parent: self, flowType: .modal)
        let fc = QRScannerFlowController(configure: config)
        fc.start(animated: true)
        return fc.resultQRCode
    }
}


protocol SendFlowEventDelegate: FlowEventDelegate {
    func goToTx(from nc: UINavigationController, account: AccountInfo, filter: Symbol?)
    func goToQRScanner(from nc: UINavigationController) -> Observable<String?>
}

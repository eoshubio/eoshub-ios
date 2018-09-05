//
//  DonateFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 26..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class DonateFlowController: FlowController, DonateFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .donate }
    
    fileprivate var account: AccountInfo?
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: AccountInfo?) {
        self.account = account
    }
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: DonationViewController.self)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DonationViewController") as! DonationViewController
        
        vc.flowDelegate = self
        vc.configure(account: account)
        
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    
   
    
    func goToSend(from nc: UINavigationController, account: AccountInfo, to: String) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = SendCurrencyFlowController(configure: config)
        let balance = Currency(balance: account.availableEOS, token: .eos)
        fc.configure(account: account, balance: balance, to: to)
        fc.start(animated: true)
    }
    
}

protocol DonateFlowEventDelegate: FlowEventDelegate {
    
    func goToSend(from nc: UINavigationController, account: AccountInfo, to: String)
  
}

//
//  SendCurrencyFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 12..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class SendCurrencyFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .wallet }
    
    var account: EOSWalletViewModel!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: EOSWalletViewModel) {
        self.account = account
    }
    
    
    func show(animated: Bool) {
        
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "SendCurrencyViewController") as? SendCurrencyViewController else { return }
//        vc.flowDelegate = self
        vc.configure(account: account)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    
}


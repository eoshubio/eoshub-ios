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
    
    var id: FlowIdentifier { return .wallet }
    
    var account: AccountInfo!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: AccountInfo) {
        self.account = account
    }
    
    
    func show(animated: Bool) {
       
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "WalletDetailViewController") as? WalletDetailViewController else { return }
        vc.flowDelegate = self
        vc.configure(viewModel: account)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    
    //MARK: WalletDetailFlowEventDelegate
    
}

protocol WalletDetailFlowEventDelegate: FlowEventDelegate {
    
}


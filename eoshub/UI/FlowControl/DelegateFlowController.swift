//
//  DelegateFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 15..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


class DelegateFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .delegatebw }
    
    var account: AccountInfo!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: AccountInfo) {
        self.account = account
    }
    
    
    func show(animated: Bool) {
        
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "DelegateViewController") as? DelegateViewController else { return }
//        vc.flowDelegate = self
        vc.configure(account: account)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
 
}

//protocol WalletDetailFlowEventDelegate: FlowEventDelegate {
//
//}

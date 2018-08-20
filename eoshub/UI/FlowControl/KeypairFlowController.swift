//
//  KeypairFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 20..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class KeypairFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .keypair }
    
    var account: AccountInfo!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: AccountInfo) {
        self.account = account
    }
    
    
    func show(animated: Bool) {
        
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "KeypairViewController") as? KeypairViewController else { return }
        vc.configure(account: account)
        show(viewController: vc, animated: animated) {
            
        }
    }
}



//
//  TokenAddFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 26..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class TokenAddFlowController: FlowController, FlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .addToken }
    
    var account: EHAccount!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: EHAccount) {
        self.account = account
    }
    
    func show(animated: Bool) {
        
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "TokenViewController") as? TokenViewController else { preconditionFailure() }
        vc.flowDelegate = self
        vc.configure(account: account)
        
        show(viewController: vc, animated: animated) {
            
        }
    }
    
}

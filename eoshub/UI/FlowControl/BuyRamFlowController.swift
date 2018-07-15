//
//  BuyRamFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 16..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


class BuyRamFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .buyram }
    
    var account: AccountInfo!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: AccountInfo) {
        self.account = account
    }
    
    
    func show(animated: Bool) {
        
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "BuyRamViewController") as? BuyRamViewController else { return }

        vc.configure(account: account)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    
}

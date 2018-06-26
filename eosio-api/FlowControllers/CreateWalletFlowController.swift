//
//  CreateWalletFlowController.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import UIKit

class CreateWalletFlowController: FlowController, CreateWalletFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .createWallet }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show() {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateWalletViewController") as? CreateWalletViewController else { preconditionFailure() }
        vc.flowEventDelgate = self
        show(viewController: vc, animated: false) {
            
        }
    }
    
    func goToWallet(nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = MainTabBarFlowController(configure: config)
        fc.start()
//        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
//        let fc = WalletFlowController(configure: config)
//        fc.start()
    }
}



protocol CreateWalletFlowEventDelegate: FlowEventDelegate {
    func goToWallet(nc: UINavigationController)
}

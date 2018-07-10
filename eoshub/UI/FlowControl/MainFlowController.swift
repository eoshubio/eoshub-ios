//
//  MainFlowController.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import UIKit

class MainFlowController: FlowController {
    var configure: FlowConfigure

    var id: FlowIdentifier { return .main }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        let nc = UINavigationController()
        
        let frame = UIScreen.main.bounds
        
        nc.view.frame = frame
        
        show(viewController: nc, animated: animated) {
            let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
            let fc = LoginFlowController(configure: config)
//            let fc = MainTabFlowController(configure: config)
            fc.start(animated: false)
            
            
            
//            if WalletManager.shared.getWallet() != nil {
//                let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
//                let fc = MainTabBarFlowController(configure: config)
//                fc.start()
//            } else {
//                //create wallet view
//                let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
//                let fc = CreateWalletFlowController(configure: config)
//                fc.start()
//            }
        }
    }
}

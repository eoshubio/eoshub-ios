//
//  WalletFlowController.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 18..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import UIKit

class WalletFlowController: FlowController, WalletFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .wallet }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show() {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalletViewController") as? WalletViewController else { preconditionFailure() }
        vc.flowEventDelegate = self
        show(viewController: vc, animated: true) {
            
        }
    }
    
    func goToSetting(nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = SettingFlowController(configure: config)
        fc.start()
    }
    
}


protocol WalletFlowEventDelegate: FlowEventDelegate {
    func goToSetting(nc: UINavigationController)
}

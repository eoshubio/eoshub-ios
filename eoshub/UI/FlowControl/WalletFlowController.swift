//
//  WalletFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class WalletFlowController: FlowController, WalletFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .wallet }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalletViewController") as? WalletViewController else { preconditionFailure() }
        vc.flowDelegate = self
        show(viewController: vc, animated: animated) {
            //remove other viewControllers in navigation controller
            vc.navigationController?.viewControllers = [vc]
        }
    }
    
    
    //MARK: WalletFlowEventDelegate
    func goToSetting(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = SettingFlowController(configure: config)
        fc.start(animated: true)
    }
    
    func goToWalletDetail(from nc: UINavigationController) {
        
    }
}

protocol WalletFlowEventDelegate: FlowEventDelegate {
    
    func goToSetting(from nc: UINavigationController)
    func goToWalletDetail(from nc: UINavigationController)
}
